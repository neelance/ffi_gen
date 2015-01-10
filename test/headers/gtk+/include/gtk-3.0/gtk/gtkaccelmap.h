/* GTK - The GIMP Toolkit
 * Copyright (C) 1998, 2001 Tim Janik
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

#if !defined (__GTK_H_INSIDE__) && !defined (GTK_COMPILATION)
#error "Only <gtk/gtk.h> can be included directly."
#endif

#ifndef __GTK_ACCEL_MAP_H__
#define __GTK_ACCEL_MAP_H__


#include <gtk/gtkaccelgroup.h>

G_BEGIN_DECLS

/* --- global GtkAccelMap object --- */
#define GTK_TYPE_ACCEL_MAP                (gtk_accel_map_get_type ())
#define GTK_ACCEL_MAP(accel_map)	  (G_TYPE_CHECK_INSTANCE_CAST ((accel_map), GTK_TYPE_ACCEL_MAP, GtkAccelMap))
#define GTK_ACCEL_MAP_CLASS(klass)	  (G_TYPE_CHECK_CLASS_CAST ((klass), GTK_TYPE_ACCEL_MAP, GtkAccelMapClass))
#define GTK_IS_ACCEL_MAP(accel_map)	  (G_TYPE_CHECK_INSTANCE_TYPE ((accel_map), GTK_TYPE_ACCEL_MAP))
#define GTK_IS_ACCEL_MAP_CLASS(klass)	  (G_TYPE_CHECK_CLASS_TYPE ((klass), GTK_TYPE_ACCEL_MAP))
#define GTK_ACCEL_MAP_GET_CLASS(obj)      (G_TYPE_INSTANCE_GET_CLASS ((obj), GTK_TYPE_ACCEL_MAP, GtkAccelMapClass))

typedef struct _GtkAccelMap      GtkAccelMap;
typedef struct _GtkAccelMapClass GtkAccelMapClass;

/* --- notifier --- */
/**
 * GtkAccelMapForeach:
 * @data: User data passed to gtk_accel_map_foreach() or
 *  gtk_accel_map_foreach_unfiltered()
 * @accel_path: Accel path of the current accelerator
 * @accel_key: Key of the current accelerator
 * @accel_mods: Modifiers of the current accelerator
 * @changed: Changed flag of the accelerator (if %TRUE, accelerator has changed
 *  during runtime and would need to be saved during an accelerator dump)
 */
typedef void (*GtkAccelMapForeach)		(gpointer	 data,
						 const gchar	*accel_path,
						 guint           accel_key,
						 GdkModifierType accel_mods,
						 gboolean	 changed);


/* --- public API --- */

void	   gtk_accel_map_add_entry	(const gchar		*accel_path,
					 guint			 accel_key,
					 GdkModifierType         accel_mods);
gboolean   gtk_accel_map_lookup_entry	(const gchar		*accel_path,
					 GtkAccelKey		*key);
gboolean   gtk_accel_map_change_entry	(const gchar		*accel_path,
					 guint			 accel_key,
					 GdkModifierType	 accel_mods,
					 gboolean		 replace);
void	   gtk_accel_map_load		(const gchar		*file_name);
void	   gtk_accel_map_save		(const gchar		*file_name);
void	   gtk_accel_map_foreach	(gpointer		 data,
					 GtkAccelMapForeach	 foreach_func);
void	   gtk_accel_map_load_fd	(gint			 fd);
void	   gtk_accel_map_load_scanner	(GScanner		*scanner);
void	   gtk_accel_map_save_fd	(gint			 fd);

void       gtk_accel_map_lock_path      (const gchar            *accel_path);
void       gtk_accel_map_unlock_path    (const gchar            *accel_path);

/* --- filter functions --- */
void	gtk_accel_map_add_filter	 (const gchar		*filter_pattern);
void	gtk_accel_map_foreach_unfiltered (gpointer		 data,
					  GtkAccelMapForeach	 foreach_func);

/* --- notification --- */
GType        gtk_accel_map_get_type (void) G_GNUC_CONST;
GtkAccelMap *gtk_accel_map_get      (void);


G_END_DECLS

#endif /* __GTK_ACCEL_MAP_H__ */
