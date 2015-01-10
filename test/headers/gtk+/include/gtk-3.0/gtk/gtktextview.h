/* GTK - The GIMP Toolkit
 * gtktextview.h Copyright (C) 2000 Red Hat, Inc.
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

#ifndef __GTK_TEXT_VIEW_H__
#define __GTK_TEXT_VIEW_H__

#include <gtk/gtkcontainer.h>
#include <gtk/gtkimcontext.h>
#include <gtk/gtktextbuffer.h>
#include <gtk/gtkmenu.h>

G_BEGIN_DECLS

#define GTK_TYPE_TEXT_VIEW             (gtk_text_view_get_type ())
#define GTK_TEXT_VIEW(obj)             (G_TYPE_CHECK_INSTANCE_CAST ((obj), GTK_TYPE_TEXT_VIEW, GtkTextView))
#define GTK_TEXT_VIEW_CLASS(klass)     (G_TYPE_CHECK_CLASS_CAST ((klass), GTK_TYPE_TEXT_VIEW, GtkTextViewClass))
#define GTK_IS_TEXT_VIEW(obj)          (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GTK_TYPE_TEXT_VIEW))
#define GTK_IS_TEXT_VIEW_CLASS(klass)  (G_TYPE_CHECK_CLASS_TYPE ((klass), GTK_TYPE_TEXT_VIEW))
#define GTK_TEXT_VIEW_GET_CLASS(obj)   (G_TYPE_INSTANCE_GET_CLASS ((obj), GTK_TYPE_TEXT_VIEW, GtkTextViewClass))

typedef enum
{
  GTK_TEXT_WINDOW_PRIVATE,
  GTK_TEXT_WINDOW_WIDGET,
  GTK_TEXT_WINDOW_TEXT,
  GTK_TEXT_WINDOW_LEFT,
  GTK_TEXT_WINDOW_RIGHT,
  GTK_TEXT_WINDOW_TOP,
  GTK_TEXT_WINDOW_BOTTOM
} GtkTextWindowType;

/**
 * GTK_TEXT_VIEW_PRIORITY_VALIDATE:
 *
 * The priority at which the text view validates onscreen lines
 * in an idle job in the background.
 */
#define GTK_TEXT_VIEW_PRIORITY_VALIDATE (GDK_PRIORITY_REDRAW + 5)

typedef struct _GtkTextView        GtkTextView;
typedef struct _GtkTextViewPrivate GtkTextViewPrivate;
typedef struct _GtkTextViewClass   GtkTextViewClass;

struct _GtkTextView
{
  GtkContainer parent_instance;

  GtkTextViewPrivate *priv;
};

struct _GtkTextViewClass
{
  GtkContainerClass parent_class;

  void (* populate_popup)           (GtkTextView    *text_view,
                                     GtkMenu        *menu);

  /* These are all RUN_ACTION signals for keybindings */

  /* move insertion point */
  void (* move_cursor) (GtkTextView    *text_view,
                        GtkMovementStep step,
                        gint            count,
                        gboolean        extend_selection);

  /* move the "anchor" (what Emacs calls the mark) to the cursor position */
  void (* set_anchor)  (GtkTextView    *text_view);

  /* Edits */
  void (* insert_at_cursor)      (GtkTextView *text_view,
                                  const gchar *str);
  void (* delete_from_cursor)    (GtkTextView  *text_view,
                                  GtkDeleteType type,
                                  gint          count);
  void (* backspace)             (GtkTextView *text_view);

  /* cut copy paste */
  void (* cut_clipboard)   (GtkTextView *text_view);
  void (* copy_clipboard)  (GtkTextView *text_view);
  void (* paste_clipboard) (GtkTextView *text_view);
  /* overwrite */
  void (* toggle_overwrite) (GtkTextView *text_view);

  /* Padding for future expansion */
  void (*_gtk_reserved1) (void);
  void (*_gtk_reserved2) (void);
  void (*_gtk_reserved3) (void);
  void (*_gtk_reserved4) (void);
  void (*_gtk_reserved5) (void);
  void (*_gtk_reserved6) (void);
  void (*_gtk_reserved7) (void);
  void (*_gtk_reserved8) (void);
};

GType          gtk_text_view_get_type              (void) G_GNUC_CONST;
GtkWidget *    gtk_text_view_new                   (void);
GtkWidget *    gtk_text_view_new_with_buffer       (GtkTextBuffer *buffer);
void           gtk_text_view_set_buffer            (GtkTextView   *text_view,
                                                    GtkTextBuffer *buffer);
GtkTextBuffer *gtk_text_view_get_buffer            (GtkTextView   *text_view);
gboolean       gtk_text_view_scroll_to_iter        (GtkTextView   *text_view,
                                                    GtkTextIter   *iter,
                                                    gdouble        within_margin,
                                                    gboolean       use_align,
                                                    gdouble        xalign,
                                                    gdouble        yalign);
void           gtk_text_view_scroll_to_mark        (GtkTextView   *text_view,
                                                    GtkTextMark   *mark,
                                                    gdouble        within_margin,
                                                    gboolean       use_align,
                                                    gdouble        xalign,
                                                    gdouble        yalign);
void           gtk_text_view_scroll_mark_onscreen  (GtkTextView   *text_view,
                                                    GtkTextMark   *mark);
gboolean       gtk_text_view_move_mark_onscreen    (GtkTextView   *text_view,
                                                    GtkTextMark   *mark);
gboolean       gtk_text_view_place_cursor_onscreen (GtkTextView   *text_view);

void           gtk_text_view_get_visible_rect      (GtkTextView   *text_view,
                                                    GdkRectangle  *visible_rect);
void           gtk_text_view_set_cursor_visible    (GtkTextView   *text_view,
                                                    gboolean       setting);
gboolean       gtk_text_view_get_cursor_visible    (GtkTextView   *text_view);

void           gtk_text_view_get_cursor_locations  (GtkTextView       *text_view,
                                                    const GtkTextIter *iter,
                                                    GdkRectangle      *strong,
                                                    GdkRectangle      *weak);
void           gtk_text_view_get_iter_location     (GtkTextView   *text_view,
                                                    const GtkTextIter *iter,
                                                    GdkRectangle  *location);
void           gtk_text_view_get_iter_at_location  (GtkTextView   *text_view,
                                                    GtkTextIter   *iter,
                                                    gint           x,
                                                    gint           y);
void           gtk_text_view_get_iter_at_position  (GtkTextView   *text_view,
                                                    GtkTextIter   *iter,
						    gint          *trailing,
                                                    gint           x,
                                                    gint           y);
void           gtk_text_view_get_line_yrange       (GtkTextView       *text_view,
                                                    const GtkTextIter *iter,
                                                    gint              *y,
                                                    gint              *height);

void           gtk_text_view_get_line_at_y         (GtkTextView       *text_view,
                                                    GtkTextIter       *target_iter,
                                                    gint               y,
                                                    gint              *line_top);

void gtk_text_view_buffer_to_window_coords (GtkTextView       *text_view,
                                            GtkTextWindowType  win,
                                            gint               buffer_x,
                                            gint               buffer_y,
                                            gint              *window_x,
                                            gint              *window_y);
void gtk_text_view_window_to_buffer_coords (GtkTextView       *text_view,
                                            GtkTextWindowType  win,
                                            gint               window_x,
                                            gint               window_y,
                                            gint              *buffer_x,
                                            gint              *buffer_y);

GDK_DEPRECATED_IN_3_0_FOR(gtk_scrollable_get_hadjustment)
GtkAdjustment*   gtk_text_view_get_hadjustment (GtkTextView   *text_view);
GDK_DEPRECATED_IN_3_0_FOR(gtk_scrollable_get_vadjustment)
GtkAdjustment*   gtk_text_view_get_vadjustment (GtkTextView   *text_view);

GdkWindow*        gtk_text_view_get_window      (GtkTextView       *text_view,
                                                 GtkTextWindowType  win);
GtkTextWindowType gtk_text_view_get_window_type (GtkTextView       *text_view,
                                                 GdkWindow         *window);

void gtk_text_view_set_border_window_size (GtkTextView       *text_view,
                                           GtkTextWindowType  type,
                                           gint               size);
gint gtk_text_view_get_border_window_size (GtkTextView       *text_view,
					   GtkTextWindowType  type);

gboolean gtk_text_view_forward_display_line           (GtkTextView       *text_view,
                                                       GtkTextIter       *iter);
gboolean gtk_text_view_backward_display_line          (GtkTextView       *text_view,
                                                       GtkTextIter       *iter);
gboolean gtk_text_view_forward_display_line_end       (GtkTextView       *text_view,
                                                       GtkTextIter       *iter);
gboolean gtk_text_view_backward_display_line_start    (GtkTextView       *text_view,
                                                       GtkTextIter       *iter);
gboolean gtk_text_view_starts_display_line            (GtkTextView       *text_view,
                                                       const GtkTextIter *iter);
gboolean gtk_text_view_move_visually                  (GtkTextView       *text_view,
                                                       GtkTextIter       *iter,
                                                       gint               count);

gboolean        gtk_text_view_im_context_filter_keypress        (GtkTextView       *text_view,
                                                                 GdkEventKey       *event);
void            gtk_text_view_reset_im_context                  (GtkTextView       *text_view);

/* Adding child widgets */
void gtk_text_view_add_child_at_anchor (GtkTextView          *text_view,
                                        GtkWidget            *child,
                                        GtkTextChildAnchor   *anchor);

void gtk_text_view_add_child_in_window (GtkTextView          *text_view,
                                        GtkWidget            *child,
                                        GtkTextWindowType     which_window,
                                        /* window coordinates */
                                        gint                  xpos,
                                        gint                  ypos);

void gtk_text_view_move_child          (GtkTextView          *text_view,
                                        GtkWidget            *child,
                                        /* window coordinates */
                                        gint                  xpos,
                                        gint                  ypos);

/* Default style settings (fallbacks if no tag affects the property) */

void             gtk_text_view_set_wrap_mode          (GtkTextView      *text_view,
                                                       GtkWrapMode       wrap_mode);
GtkWrapMode      gtk_text_view_get_wrap_mode          (GtkTextView      *text_view);
void             gtk_text_view_set_editable           (GtkTextView      *text_view,
                                                       gboolean          setting);
gboolean         gtk_text_view_get_editable           (GtkTextView      *text_view);
void             gtk_text_view_set_overwrite          (GtkTextView      *text_view,
						       gboolean          overwrite);
gboolean         gtk_text_view_get_overwrite          (GtkTextView      *text_view);
void		 gtk_text_view_set_accepts_tab        (GtkTextView	*text_view,
						       gboolean		 accepts_tab);
gboolean	 gtk_text_view_get_accepts_tab        (GtkTextView	*text_view);
void             gtk_text_view_set_pixels_above_lines (GtkTextView      *text_view,
                                                       gint              pixels_above_lines);
gint             gtk_text_view_get_pixels_above_lines (GtkTextView      *text_view);
void             gtk_text_view_set_pixels_below_lines (GtkTextView      *text_view,
                                                       gint              pixels_below_lines);
gint             gtk_text_view_get_pixels_below_lines (GtkTextView      *text_view);
void             gtk_text_view_set_pixels_inside_wrap (GtkTextView      *text_view,
                                                       gint              pixels_inside_wrap);
gint             gtk_text_view_get_pixels_inside_wrap (GtkTextView      *text_view);
void             gtk_text_view_set_justification      (GtkTextView      *text_view,
                                                       GtkJustification  justification);
GtkJustification gtk_text_view_get_justification      (GtkTextView      *text_view);
void             gtk_text_view_set_left_margin        (GtkTextView      *text_view,
                                                       gint              left_margin);
gint             gtk_text_view_get_left_margin        (GtkTextView      *text_view);
void             gtk_text_view_set_right_margin       (GtkTextView      *text_view,
                                                       gint              right_margin);
gint             gtk_text_view_get_right_margin       (GtkTextView      *text_view);
void             gtk_text_view_set_indent             (GtkTextView      *text_view,
                                                       gint              indent);
gint             gtk_text_view_get_indent             (GtkTextView      *text_view);
void             gtk_text_view_set_tabs               (GtkTextView      *text_view,
                                                       PangoTabArray    *tabs);
PangoTabArray*   gtk_text_view_get_tabs               (GtkTextView      *text_view);

/* note that the return value of this changes with the theme */
GtkTextAttributes* gtk_text_view_get_default_attributes (GtkTextView    *text_view);

GDK_AVAILABLE_IN_3_6
void             gtk_text_view_set_input_purpose      (GtkTextView      *text_view,
                                                       GtkInputPurpose   purpose);
GDK_AVAILABLE_IN_3_6
GtkInputPurpose  gtk_text_view_get_input_purpose      (GtkTextView      *text_view);

GDK_AVAILABLE_IN_3_6
void             gtk_text_view_set_input_hints        (GtkTextView      *text_view,
                                                       GtkInputHints     hints);
GDK_AVAILABLE_IN_3_6
GtkInputHints    gtk_text_view_get_input_hints        (GtkTextView      *text_view);


G_END_DECLS

#endif /* __GTK_TEXT_VIEW_H__ */
