/* GTK - The GIMP Toolkit
 * Copyright (C) 1995-1997 Peter Mattis, Spencer Kimball and Josh MacDonald
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Modified by the GTK+ Team and others 1997-2000.  See the AUTHORS
 * file for a list of people on the GTK+ Team.  See the ChangeLog
 * files for a list of changes.  These files are distributed with
 * GTK+ at ftp://ftp.gtk.org/pub/gtk/.
 */

#if !defined (__GTK_H_INSIDE__) && !defined (GTK_COMPILATION)
#error "Only <gtk/gtk.h> can be included directly."
#endif

#ifndef __GTK_MAIN_H__
#define __GTK_MAIN_H__


#include <gdk/gdk.h>
#include <gtk/gtkwidget.h>
#ifdef G_PLATFORM_WIN32
#include <gtk/gtkbox.h>
#include <gtk/gtkwindow.h>
#endif

G_BEGIN_DECLS

/**
 * GTK_PRIORITY_RESIZE:
 *
 * Use this priority for functionality related to size allocation.
 *
 * It is used internally by GTK+ to compute the sizes of widgets.
 * This priority is higher than %GDK_PRIORITY_REDRAW to avoid
 * resizing a widget which was just redrawn.
 */
#define GTK_PRIORITY_RESIZE (G_PRIORITY_HIGH_IDLE + 10)

/**
 * GtkKeySnoopFunc:
 * @grab_widget: the widget to which the event will be delivered
 * @event: the key event
 * @func_data: data supplied to gtk_key_snooper_install()
 *
 * Key snooper functions are called before normal event delivery.
 * They can be used to implement custom key event handling.
 *
 * Returns: %TRUE to stop further processing of @event, %FALSE to continue.
 */
typedef gint (*GtkKeySnoopFunc) (GtkWidget   *grab_widget,
                                 GdkEventKey *event,
                                 gpointer     func_data);

/* GTK+ version
 */
guint gtk_get_major_version (void) G_GNUC_CONST;
guint gtk_get_minor_version (void) G_GNUC_CONST;
guint gtk_get_micro_version (void) G_GNUC_CONST;
guint gtk_get_binary_age    (void) G_GNUC_CONST;
guint gtk_get_interface_age (void) G_GNUC_CONST;

#define gtk_major_version gtk_get_major_version ()
#define gtk_minor_version gtk_get_minor_version ()
#define gtk_micro_version gtk_get_micro_version ()
#define gtk_binary_age gtk_get_binary_age ()
#define gtk_interface_age gtk_get_interface_age ()

const gchar* gtk_check_version (guint   required_major,
                                guint   required_minor,
                                guint   required_micro);


/* Initialization, exit, mainloop and miscellaneous routines
 */

gboolean gtk_parse_args           (int    *argc,
                                   char ***argv);

void     gtk_init                 (int    *argc,
                                   char ***argv);

gboolean gtk_init_check           (int    *argc,
                                   char ***argv);

gboolean gtk_init_with_args       (gint                 *argc,
                                   gchar              ***argv,
                                   const gchar          *parameter_string,
                                   const GOptionEntry   *entries,
                                   const gchar          *translation_domain,
                                   GError              **error);

GOptionGroup *gtk_get_option_group (gboolean open_default_display);

#ifdef G_OS_WIN32

/* Variants that are used to check for correct struct packing
 * when building GTK+-using code.
 */
void     gtk_init_abi_check       (int    *argc,
                                   char ***argv,
                                   int     num_checks,
                                   size_t  sizeof_GtkWindow,
                                   size_t  sizeof_GtkBox);
gboolean gtk_init_check_abi_check (int    *argc,
                                   char ***argv,
                                   int     num_checks,
                                   size_t  sizeof_GtkWindow,
                                   size_t  sizeof_GtkBox);

#define gtk_init(argc, argv) gtk_init_abi_check (argc, argv, 2, sizeof (GtkWindow), sizeof (GtkBox))
#define gtk_init_check(argc, argv) gtk_init_check_abi_check (argc, argv, 2, sizeof (GtkWindow), sizeof (GtkBox))

#endif

void           gtk_disable_setlocale    (void);
PangoLanguage *gtk_get_default_language (void);
gboolean       gtk_events_pending       (void);

void       gtk_main_do_event       (GdkEvent           *event);
void       gtk_main                (void);
guint      gtk_main_level          (void);
void       gtk_main_quit           (void);
gboolean   gtk_main_iteration      (void);
gboolean   gtk_main_iteration_do   (gboolean            blocking);

gboolean   gtk_true                (void) G_GNUC_CONST;
gboolean   gtk_false               (void) G_GNUC_CONST;

void       gtk_grab_add            (GtkWidget          *widget);
GtkWidget* gtk_grab_get_current    (void);
void       gtk_grab_remove         (GtkWidget          *widget);

void       gtk_device_grab_add     (GtkWidget          *widget,
                                    GdkDevice          *device,
                                    gboolean            block_others);
void       gtk_device_grab_remove  (GtkWidget          *widget,
                                    GdkDevice          *device);

GDK_DEPRECATED_IN_3_4
guint      gtk_key_snooper_install (GtkKeySnoopFunc snooper,
                                    gpointer        func_data);
GDK_DEPRECATED_IN_3_4
void       gtk_key_snooper_remove  (guint           snooper_handler_id);

GdkEvent * gtk_get_current_event        (void);
guint32    gtk_get_current_event_time   (void);
gboolean   gtk_get_current_event_state  (GdkModifierType *state);
GdkDevice *gtk_get_current_event_device (void);

GtkWidget *gtk_get_event_widget         (GdkEvent        *event);

void       gtk_propagate_event          (GtkWidget       *widget,
                                         GdkEvent        *event);


G_END_DECLS

#endif /* __GTK_MAIN_H__ */
