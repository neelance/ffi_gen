/* GDK - The GIMP Drawing Kit
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

#if !defined (__GDK_H_INSIDE__) && !defined (GDK_COMPILATION)
#error "Only <gdk/gdk.h> can be included directly."
#endif

#ifndef __GDK_PROPERTY_H__
#define __GDK_PROPERTY_H__

#include <gdk/gdktypes.h>

G_BEGIN_DECLS


/**
 * GdkPropMode:
 * @GDK_PROP_MODE_REPLACE: the new data replaces the existing data.
 * @GDK_PROP_MODE_PREPEND: the new data is prepended to the existing data.
 * @GDK_PROP_MODE_APPEND: the new data is appended to the existing data.
 *
 * Describes how existing data is combined with new data when
 * using gdk_property_change().
 */
typedef enum
{
  GDK_PROP_MODE_REPLACE,
  GDK_PROP_MODE_PREPEND,
  GDK_PROP_MODE_APPEND
} GdkPropMode;


GdkAtom gdk_atom_intern (const gchar *atom_name,
                         gboolean     only_if_exists);
GdkAtom gdk_atom_intern_static_string (const gchar *atom_name);
gchar*  gdk_atom_name   (GdkAtom      atom);


gboolean gdk_property_get    (GdkWindow     *window,
                              GdkAtom        property,
                              GdkAtom        type,
                              gulong         offset,
                              gulong         length,
                              gint           pdelete,
                              GdkAtom       *actual_property_type,
                              gint          *actual_format,
                              gint          *actual_length,
                              guchar       **data);
void     gdk_property_change (GdkWindow     *window,
                              GdkAtom        property,
                              GdkAtom        type,
                              gint           format,
                              GdkPropMode    mode,
                              const guchar  *data,
                              gint           nelements);
void     gdk_property_delete (GdkWindow     *window,
                              GdkAtom        property);

gint   gdk_text_property_to_utf8_list_for_display (GdkDisplay     *display,
                                                   GdkAtom         encoding,
                                                   gint            format,
                                                   const guchar   *text,
                                                   gint            length,
                                                   gchar        ***list);

gchar *gdk_utf8_to_string_target                  (const gchar    *str);

G_END_DECLS

#endif /* __GDK_PROPERTY_H__ */
