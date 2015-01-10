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

#ifndef __GDK_VISUAL_H__
#define __GDK_VISUAL_H__

#include <gdk/gdktypes.h>

G_BEGIN_DECLS

#define GDK_TYPE_VISUAL              (gdk_visual_get_type ())
#define GDK_VISUAL(object)           (G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_VISUAL, GdkVisual))
#define GDK_IS_VISUAL(object)        (G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_VISUAL))

/**
 * GdkVisualType:
 * @GDK_VISUAL_STATIC_GRAY: Each pixel value indexes a grayscale value
 *     directly.
 * @GDK_VISUAL_GRAYSCALE: Each pixel is an index into a color map that
 *     maps pixel values into grayscale values. The color map can be
 *     changed by an application.
 * @GDK_VISUAL_STATIC_COLOR: Each pixel value is an index into a predefined,
 *     unmodifiable color map that maps pixel values into RGB values.
 * @GDK_VISUAL_PSEUDO_COLOR: Each pixel is an index into a color map that
 *     maps pixel values into rgb values. The color map can be changed by
 *     an application.
 * @GDK_VISUAL_TRUE_COLOR: Each pixel value directly contains red, green,
 *     and blue components. Use gdk_visual_get_red_pixel_details(), etc,
 *     to obtain information about how the components are assembled into
 *     a pixel value.
 * @GDK_VISUAL_DIRECT_COLOR: Each pixel value contains red, green, and blue
 *     components as for %GDK_VISUAL_TRUE_COLOR, but the components are
 *     mapped via a color table into the final output table instead of
 *     being converted directly.
 *
 * A set of values that describe the manner in which the pixel values
 * for a visual are converted into RGB values for display.
 */
typedef enum
{
  GDK_VISUAL_STATIC_GRAY,
  GDK_VISUAL_GRAYSCALE,
  GDK_VISUAL_STATIC_COLOR,
  GDK_VISUAL_PSEUDO_COLOR,
  GDK_VISUAL_TRUE_COLOR,
  GDK_VISUAL_DIRECT_COLOR
} GdkVisualType;

/**
 * GdkVisual:
 *
 * The #GdkVisual structure contains information about
 * a particular visual.
 */

GType         gdk_visual_get_type            (void) G_GNUC_CONST;

#ifndef GDK_MULTIHEAD_SAFE
gint          gdk_visual_get_best_depth      (void);
GdkVisualType gdk_visual_get_best_type       (void);
GdkVisual*    gdk_visual_get_system          (void);
GdkVisual*    gdk_visual_get_best            (void);
GdkVisual*    gdk_visual_get_best_with_depth (gint           depth);
GdkVisual*    gdk_visual_get_best_with_type  (GdkVisualType  visual_type);
GdkVisual*    gdk_visual_get_best_with_both  (gint           depth,
                                              GdkVisualType  visual_type);

void gdk_query_depths       (gint           **depths,
                             gint            *count);
void gdk_query_visual_types (GdkVisualType  **visual_types,
                             gint            *count);

GList* gdk_list_visuals (void);
#endif

GdkScreen    *gdk_visual_get_screen (GdkVisual *visual);

GdkVisualType gdk_visual_get_visual_type         (GdkVisual *visual);
gint          gdk_visual_get_depth               (GdkVisual *visual);
GdkByteOrder  gdk_visual_get_byte_order          (GdkVisual *visual);
gint          gdk_visual_get_colormap_size       (GdkVisual *visual);
gint          gdk_visual_get_bits_per_rgb        (GdkVisual *visual);
void          gdk_visual_get_red_pixel_details   (GdkVisual *visual,
                                                  guint32   *mask,
                                                  gint      *shift,
                                                  gint      *precision);
void          gdk_visual_get_green_pixel_details (GdkVisual *visual,
                                                  guint32   *mask,
                                                  gint      *shift,
                                                  gint      *precision);
void          gdk_visual_get_blue_pixel_details  (GdkVisual *visual,
                                                  guint32   *mask,
                                                  gint      *shift,
                                                  gint      *precision);

G_END_DECLS

#endif /* __GDK_VISUAL_H__ */
