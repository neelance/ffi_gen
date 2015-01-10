/*
 * gtknumerableicon.h: an emblemed icon with number emblems
 *
 * Copyright (C) 2010 Red Hat, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Cosimo Cecchi <cosimoc@redhat.com>
 */

#if !defined (__GTK_H_INSIDE__) && !defined (GTK_COMPILATION)
#error "Only <gtk/gtk.h> can be included directly."
#endif

#ifndef __GTK_NUMERABLE_ICON_H__
#define __GTK_NUMERABLE_ICON_H__

#include <gio/gio.h>
#include <gtk/gtkstylecontext.h>

G_BEGIN_DECLS

#define GTK_TYPE_NUMERABLE_ICON                  (gtk_numerable_icon_get_type ())
#define GTK_NUMERABLE_ICON(obj)                  (G_TYPE_CHECK_INSTANCE_CAST ((obj), GTK_TYPE_NUMERABLE_ICON, GtkNumerableIcon))
#define GTK_NUMERABLE_ICON_CLASS(klass)          (G_TYPE_CHECK_CLASS_CAST ((klass), GTK_TYPE_NUMERABLE_ICON, GtkNumerableIconClass))
#define GTK_IS_NUMERABLE_ICON(obj)               (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GTK_TYPE_NUMERABLE_ICON))
#define GTK_IS_NUMERABLE_ICON_CLASS(klass)       (G_TYPE_CHECK_CLASS_TYPE ((klass), GTK_TYPE_NUMERABLE_ICON))
#define GTK_NUMERABLE_ICON_GET_CLASS(obj)        (G_TYPE_INSTANCE_GET_CLASS ((obj), GTK_TYPE_NUMERABLE_ICON, GtkNumerableIconClass))

typedef struct _GtkNumerableIcon        GtkNumerableIcon;
typedef struct _GtkNumerableIconClass   GtkNumerableIconClass;
typedef struct _GtkNumerableIconPrivate GtkNumerableIconPrivate;

struct _GtkNumerableIcon {
  GEmblemedIcon parent;

  /*< private >*/
  GtkNumerableIconPrivate *priv;
};

struct _GtkNumerableIconClass {
  GEmblemedIconClass parent_class;

  /* padding for future class expansion */
  gpointer padding[16];
};

GType             gtk_numerable_icon_get_type                 (void) G_GNUC_CONST;

GIcon *           gtk_numerable_icon_new                      (GIcon            *base_icon);
GIcon *           gtk_numerable_icon_new_with_style_context   (GIcon            *base_icon,
                                                               GtkStyleContext  *context);

GtkStyleContext * gtk_numerable_icon_get_style_context        (GtkNumerableIcon *self);
void              gtk_numerable_icon_set_style_context        (GtkNumerableIcon *self,
                                                               GtkStyleContext  *style);

gint              gtk_numerable_icon_get_count                (GtkNumerableIcon *self);
void              gtk_numerable_icon_set_count                (GtkNumerableIcon *self,
                                                               gint count);

const gchar *     gtk_numerable_icon_get_label                (GtkNumerableIcon *self);
void              gtk_numerable_icon_set_label                (GtkNumerableIcon *self,
                                                               const gchar      *label);

void              gtk_numerable_icon_set_background_gicon     (GtkNumerableIcon *self,
                                                               GIcon            *icon);
GIcon *           gtk_numerable_icon_get_background_gicon     (GtkNumerableIcon *self);

void              gtk_numerable_icon_set_background_icon_name (GtkNumerableIcon *self,
                                                               const gchar      *icon_name);
const gchar *     gtk_numerable_icon_get_background_icon_name (GtkNumerableIcon *self);

G_END_DECLS

#endif /* __GTK_NUMERABLE_ICON_H__ */
