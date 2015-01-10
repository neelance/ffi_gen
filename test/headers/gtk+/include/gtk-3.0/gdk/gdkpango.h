/* GDK - The GIMP Drawing Kit
 * Copyright (C) 2000 Red Hat, Inc. 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 */

#if !defined (__GDK_H_INSIDE__) && !defined (GDK_COMPILATION)
#error "Only <gdk/gdk.h> can be included directly."
#endif

#ifndef __GDK_PANGO_H__
#define __GDK_PANGO_H__

#include <gdk/gdktypes.h>

G_BEGIN_DECLS

/************************************************************************/

PangoContext *gdk_pango_context_get_for_screen (GdkScreen    *screen);
#ifndef GDK_MULTIHEAD_SAFE
PangoContext *gdk_pango_context_get            (void);
#endif


/* Get a clip region to draw only part of a layout or
 * line. index_ranges contains alternating range starts/stops. The
 * region is the region which contains the given ranges, i.e. if you
 * draw with the region as clip, only the given ranges are drawn.
 */

cairo_region_t    *gdk_pango_layout_line_get_clip_region (PangoLayoutLine *line,
                                                     gint             x_origin,
                                                     gint             y_origin,
                                                     const gint      *index_ranges,
                                                     gint             n_ranges);
cairo_region_t    *gdk_pango_layout_get_clip_region      (PangoLayout     *layout,
                                                     gint             x_origin,
                                                     gint             y_origin,
                                                     const gint      *index_ranges,
                                                     gint             n_ranges);

G_END_DECLS

#endif /* __GDK_PANGO_H__ */
