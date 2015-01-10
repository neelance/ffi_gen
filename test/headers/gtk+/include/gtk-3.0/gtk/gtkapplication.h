/*
 * Copyright © 2010 Codethink Limited
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the licence, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Ryan Lortie <desrt@desrt.ca>
 */

#if !defined (__GTK_H_INSIDE__) && !defined (GTK_COMPILATION)
#error "Only <gtk/gtk.h> can be included directly."
#endif

#ifndef __GTK_APPLICATION_H__
#define __GTK_APPLICATION_H__

#include <gtk/gtkwidget.h>
#include <gio/gio.h>

G_BEGIN_DECLS

#define GTK_TYPE_APPLICATION            (gtk_application_get_type ())
#define GTK_APPLICATION(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), GTK_TYPE_APPLICATION, GtkApplication))
#define GTK_APPLICATION_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), GTK_TYPE_APPLICATION, GtkApplicationClass))
#define GTK_IS_APPLICATION(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GTK_TYPE_APPLICATION))
#define GTK_IS_APPLICATION_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), GTK_TYPE_APPLICATION))
#define GTK_APPLICATION_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), GTK_TYPE_APPLICATION, GtkApplicationClass))

typedef struct _GtkApplication        GtkApplication;
typedef struct _GtkApplicationClass   GtkApplicationClass;
typedef struct _GtkApplicationPrivate GtkApplicationPrivate;

struct _GtkApplication
{
  GApplication parent;

  /*< private >*/
  GtkApplicationPrivate *priv;
};

struct _GtkApplicationClass
{
  GApplicationClass parent_class;

  void (*window_added)   (GtkApplication *application,
                          GtkWindow      *window);
  void (*window_removed) (GtkApplication *application,
                          GtkWindow      *window);

  /*< private >*/
  gpointer padding[12];
};

GType            gtk_application_get_type      (void) G_GNUC_CONST;

GtkApplication * gtk_application_new           (const gchar       *application_id,
                                                GApplicationFlags  flags);

void             gtk_application_add_window    (GtkApplication    *application,
                                                GtkWindow         *window);

void             gtk_application_remove_window (GtkApplication    *application,
                                                GtkWindow         *window);
GList *          gtk_application_get_windows   (GtkApplication    *application);

GDK_AVAILABLE_IN_3_4
GMenuModel *     gtk_application_get_app_menu  (GtkApplication    *application);
GDK_AVAILABLE_IN_3_4
void             gtk_application_set_app_menu  (GtkApplication    *application,
                                                GMenuModel        *app_menu);

GDK_AVAILABLE_IN_3_4
GMenuModel *     gtk_application_get_menubar   (GtkApplication    *application);
GDK_AVAILABLE_IN_3_4
void             gtk_application_set_menubar   (GtkApplication    *application,
                                                GMenuModel        *menubar);

GDK_AVAILABLE_IN_3_4
void             gtk_application_add_accelerator    (GtkApplication  *application,
                                                     const gchar     *accelerator,
                                                     const gchar     *action_name,
                                                     GVariant        *parameter);
GDK_AVAILABLE_IN_3_4
void             gtk_application_remove_accelerator (GtkApplication *application,
                                                     const gchar    *action_name,
                                                     GVariant       *parameter);

typedef enum
{
  GTK_APPLICATION_INHIBIT_LOGOUT  = (1 << 0),
  GTK_APPLICATION_INHIBIT_SWITCH  = (1 << 1),
  GTK_APPLICATION_INHIBIT_SUSPEND = (1 << 2),
  GTK_APPLICATION_INHIBIT_IDLE    = (1 << 3)
} GtkApplicationInhibitFlags;

GDK_AVAILABLE_IN_3_4
guint            gtk_application_inhibit            (GtkApplication             *application,
                                                     GtkWindow                  *window,
                                                     GtkApplicationInhibitFlags  flags,
                                                     const gchar                *reason);
GDK_AVAILABLE_IN_3_4
void             gtk_application_uninhibit          (GtkApplication             *application,
                                                     guint                       cookie);
GDK_AVAILABLE_IN_3_4
gboolean         gtk_application_is_inhibited       (GtkApplication             *application,
                                                     GtkApplicationInhibitFlags  flags);

GDK_AVAILABLE_IN_3_6
GtkWindow *      gtk_application_get_window_by_id   (GtkApplication             *application,
                                                     guint                       id);

GDK_AVAILABLE_IN_3_6
GtkWindow *      gtk_application_get_active_window  (GtkApplication             *application);

G_END_DECLS

#endif /* __GTK_APPLICATION_H__ */

