#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <keybinder.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  FlMethodChannel* lookup_channel;
  char* bound_hotkey;
  char* last_primary;
  char* last_clipboard;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

static gchar* read_xclip(const gchar* selection) {
  gchar* cmd = g_strdup_printf("xclip -selection %s -o", selection);
  gchar* out = nullptr;
  gint status = 0;
  g_spawn_command_line_sync(cmd, &out, nullptr, &status, nullptr);
  g_free(cmd);
  if (status != 0 || out == nullptr || strlen(out) == 0) {
    g_free(out);
    return nullptr;
  }
  return out;
}

static gboolean hotkey_idle_cb(gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  g_message("[DPD-C++] hotkey_idle_cb: reading selections via xclip");

  gchar* primary = read_xclip("primary");
  gchar* clip = read_xclip("clipboard");

  gboolean primary_changed = (primary != nullptr &&
      g_strcmp0(primary, self->last_primary) != 0);
  gboolean clip_changed = (clip != nullptr &&
      g_strcmp0(clip, self->last_clipboard) != 0);

  g_message("[DPD-C++] PRIMARY='%s' changed=%d, CLIPBOARD='%s' changed=%d",
      primary ? primary : "(null)", primary_changed,
      clip ? clip : "(null)", clip_changed);

  const gchar* text = nullptr;
  if (primary_changed) {
    text = primary;
  } else if (clip_changed) {
    text = clip;
  }

  if (text != nullptr) {
    g_message("[DPD-C++] using: '%s'", text);
    g_autoptr(FlValue) word = fl_value_new_string(text);
    fl_method_channel_invoke_method(self->lookup_channel, "lookupWord",
                                    word, nullptr, nullptr, nullptr);
  } else {
    g_message("[DPD-C++] no new selection detected");
  }

  g_free(self->last_primary);
  self->last_primary = g_strdup(primary);
  g_free(self->last_clipboard);
  self->last_clipboard = g_strdup(clip);

  g_free(primary);
  g_free(clip);

  GtkWindow* window = gtk_application_get_active_window(
      GTK_APPLICATION(g_application_get_default()));
  if (window) {
    g_message("[DPD-C++] Raising window");
    gtk_window_present(window);
  }

  return G_SOURCE_REMOVE;
}

static void hotkey_callback(const char* keystring, void* user_data) {
  g_message("[DPD-C++] hotkey_callback fired: %s", keystring);
  g_idle_add(hotkey_idle_cb, user_data);
}

static void method_call_handler(FlMethodChannel* channel,
                                FlMethodCall* method_call,
                                gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "bindHotkey") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    const gchar* accelerator = fl_value_get_string(args);
    g_message("[DPD-C++] bindHotkey called: '%s'", accelerator);

    if (self->bound_hotkey != nullptr) {
      keybinder_unbind(self->bound_hotkey, hotkey_callback);
      g_free(self->bound_hotkey);
      self->bound_hotkey = nullptr;
    }

    if (strlen(accelerator) > 0) {
      gboolean ok = keybinder_bind(accelerator, hotkey_callback, self);
      g_message("[DPD-C++] keybinder_bind result: %s", ok ? "SUCCESS" : "FAILED");
      if (ok) {
        self->bound_hotkey = g_strdup(accelerator);
      }
      g_autoptr(FlMethodResponse) response =
          FL_METHOD_RESPONSE(fl_method_success_response_new(
              fl_value_new_bool(ok)));
      fl_method_call_respond(method_call, response, nullptr);
    } else {
      g_autoptr(FlMethodResponse) response =
          FL_METHOD_RESPONSE(fl_method_success_response_new(
              fl_value_new_bool(TRUE)));
      fl_method_call_respond(method_call, response, nullptr);
    }
  } else if (strcmp(method, "unbindHotkey") == 0) {
    g_message("[DPD-C++] unbindHotkey called");
    if (self->bound_hotkey != nullptr) {
      keybinder_unbind(self->bound_hotkey, hotkey_callback);
      g_free(self->bound_hotkey);
      self->bound_hotkey = nullptr;
    }
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(
            fl_value_new_bool(TRUE)));
    fl_method_call_respond(method_call, response, nullptr);
  } else {
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(method_call, response, nullptr);
  }
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  g_message("[DPD-C++] activate called");
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "dpd_flutter_app");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "dpd_flutter_app");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->lookup_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "net.dpdict.app/lookup",
      FL_METHOD_CODEC(codec));
  g_message("[DPD-C++] lookup_channel created on 'net.dpdict.app/lookup'");

  keybinder_init();
  fl_method_channel_set_method_call_handler(
      self->lookup_channel, method_call_handler, self, nullptr);
  g_message("[DPD-C++] keybinder initialized, method call handler set");

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::command_line.
static int my_application_command_line(GApplication* application,
                                       GApplicationCommandLine* cmdline) {
  MyApplication* self = MY_APPLICATION(application);
  int argc;
  gchar** argv = g_application_command_line_get_arguments(cmdline, &argc);

  g_message("[DPD-C++] command_line called, argc=%d, lookup_channel=%p", argc, (void*)self->lookup_channel);
  for (int i = 0; i < argc; i++) {
    g_message("[DPD-C++]   argv[%d] = '%s'", i, argv[i]);
  }

  if (self->lookup_channel != nullptr && argc > 1) {
    g_message("[DPD-C++] App running, sending '%s' via method channel", argv[1]);
    g_autoptr(FlValue) word = fl_value_new_string(argv[1]);
    fl_method_channel_invoke_method(self->lookup_channel, "lookupWord",
                                    word, nullptr, nullptr, nullptr);
    GtkWindow* window = gtk_application_get_active_window(GTK_APPLICATION(application));
    if (window) {
      g_message("[DPD-C++] Raising window");
      gtk_window_present(window);
    } else {
      g_message("[DPD-C++] WARNING: no active window to raise");
    }
  } else if (self->lookup_channel == nullptr) {
    g_message("[DPD-C++] First launch, storing args and activating");
    g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
    if (argc > 1) {
      self->dart_entrypoint_arguments = g_strdupv(argv + 1);
    }
    g_application_activate(application);
  }

  g_strfreev(argv);
  return 0;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  if (self->bound_hotkey != nullptr) {
    keybinder_unbind(self->bound_hotkey, hotkey_callback);
    g_free(self->bound_hotkey);
    self->bound_hotkey = nullptr;
  }
  g_free(self->last_primary);
  g_free(self->last_clipboard);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->lookup_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->command_line = my_application_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_HANDLES_COMMAND_LINE, nullptr));
}
