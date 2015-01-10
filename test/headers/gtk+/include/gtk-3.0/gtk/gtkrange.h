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

#ifndef __GTK_RANGE_H__
#define __GTK_RANGE_H__


#include <gtk/gtkwidget.h>


G_BEGIN_DECLS


#define GTK_TYPE_RANGE            (gtk_range_get_type ())
#define GTK_RANGE(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), GTK_TYPE_RANGE, GtkRange))
#define GTK_RANGE_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), GTK_TYPE_RANGE, GtkRangeClass))
#define GTK_IS_RANGE(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GTK_TYPE_RANGE))
#define GTK_IS_RANGE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), GTK_TYPE_RANGE))
#define GTK_RANGE_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), GTK_TYPE_RANGE, GtkRangeClass))

typedef struct _GtkRange              GtkRange;
typedef struct _GtkRangePrivate       GtkRangePrivate;
typedef struct _GtkRangeClass         GtkRangeClass;

struct _GtkRange
{
  GtkWidget widget;

  GtkRangePrivate *priv;
};

struct _GtkRangeClass
{
  GtkWidgetClass parent_class;

  /* what detail to pass to GTK drawing functions */
  gchar *slider_detail;
  gchar *stepper_detail;

  void (* value_changed)    (GtkRange     *range);
  void (* adjust_bounds)    (GtkRange     *range,
                             gdouble	   new_value);

  /* action signals for keybindings */
  void (* move_slider)      (GtkRange     *range,
                             GtkScrollType scroll);

  /* Virtual functions */
  void (* get_range_border) (GtkRange     *range,
                             GtkBorder    *border_);

  gboolean (* change_value) (GtkRange     *range,
                             GtkScrollType scroll,
                             gdouble       new_value);

  /* Padding for future expansion */
  void (*_gtk_reserved1) (void);
  void (*_gtk_reserved2) (void);
  void (*_gtk_reserved3) (void);
  void (*_gtk_reserved4) (void);
};


GType              gtk_range_get_type                      (void) G_GNUC_CONST;

void               gtk_range_set_adjustment                (GtkRange      *range,
                                                            GtkAdjustment *adjustment);
GtkAdjustment*     gtk_range_get_adjustment                (GtkRange      *range);

void               gtk_range_set_inverted                  (GtkRange      *range,
                                                            gboolean       setting);
gboolean           gtk_range_get_inverted                  (GtkRange      *range);

void               gtk_range_set_flippable                 (GtkRange      *range,
                                                            gboolean       flippable);
gboolean           gtk_range_get_flippable                 (GtkRange      *range);

void               gtk_range_set_slider_size_fixed         (GtkRange      *range,
                                                            gboolean       size_fixed);
gboolean           gtk_range_get_slider_size_fixed         (GtkRange      *range);

void               gtk_range_set_min_slider_size           (GtkRange      *range,
                                                            gint           min_size);
gint               gtk_range_get_min_slider_size           (GtkRange      *range);

void               gtk_range_get_range_rect                (GtkRange      *range,
                                                            GdkRectangle  *range_rect);
void               gtk_range_get_slider_range              (GtkRange      *range,
                                                            gint          *slider_start,
                                                            gint          *slider_end);

void               gtk_range_set_lower_stepper_sensitivity (GtkRange      *range,
                                                            GtkSensitivityType sensitivity);
GtkSensitivityType gtk_range_get_lower_stepper_sensitivity (GtkRange      *range);
void               gtk_range_set_upper_stepper_sensitivity (GtkRange      *range,
                                                            GtkSensitivityType sensitivity);
GtkSensitivityType gtk_range_get_upper_stepper_sensitivity (GtkRange      *range);

void               gtk_range_set_increments                (GtkRange      *range,
                                                            gdouble        step,
                                                            gdouble        page);
void               gtk_range_set_range                     (GtkRange      *range,
                                                            gdouble        min,
                                                            gdouble        max);
void               gtk_range_set_value                     (GtkRange      *range,
                                                            gdouble        value);
gdouble            gtk_range_get_value                     (GtkRange      *range);

void               gtk_range_set_show_fill_level           (GtkRange      *range,
                                                            gboolean       show_fill_level);
gboolean           gtk_range_get_show_fill_level           (GtkRange      *range);
void               gtk_range_set_restrict_to_fill_level    (GtkRange      *range,
                                                            gboolean       restrict_to_fill_level);
gboolean           gtk_range_get_restrict_to_fill_level    (GtkRange      *range);
void               gtk_range_set_fill_level                (GtkRange      *range,
                                                            gdouble        fill_level);
gdouble            gtk_range_get_fill_level                (GtkRange      *range);
void               gtk_range_set_round_digits              (GtkRange      *range,
                                                            gint           round_digits);
gint                gtk_range_get_round_digits              (GtkRange      *range);

/* internal API */
gdouble            _gtk_range_get_wheel_delta              (GtkRange       *range,
                                                            GdkEventScroll *event);
void               _gtk_range_set_has_origin               (GtkRange      *range,
                                                            gboolean       has_origin);
gboolean           _gtk_range_get_has_origin               (GtkRange      *range);
void               _gtk_range_set_stop_values              (GtkRange      *range,
                                                            gdouble       *values,
                                                            gint           n_values);
gint               _gtk_range_get_stop_positions           (GtkRange      *range,
                                                            gint         **values);
void               _gtk_range_set_steppers                 (GtkRange      *range,
                                                            gboolean       has_a,
                                                            gboolean       has_b,
                                                            gboolean       has_c,
                                                            gboolean       has_d);

G_END_DECLS


#endif /* __GTK_RANGE_H__ */
