/* gdkversionmacros.h - version boundaries checks
 * Copyright (C) 2012 Red Hat, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.▸ See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#if !defined (__GDK_H_INSIDE__) && !defined (GDK_COMPILATION)
#error "Only <gdk/gdk.h> can be included directly."
#endif

#ifndef __GDK_VERSION_MACROS_H__
#define __GDK_VERSION_MACROS_H__

#include <glib.h>

#define GDK_MAJOR_VERSION (3)
#define GDK_MINOR_VERSION (6)
#define GDK_MICRO_VERSION (4)

/**
 * GDK_DISABLE_DEPRECATION_WARNINGS:
 *
 * A macro that should be defined before including the gdk.h header.
 * If it is defined, no compiler warnings will be produced for uses
 * of deprecated GDK and GTK+ APIs.
 */

#ifdef GDK_DISABLE_DEPRECATION_WARNINGS
#define GDK_DEPRECATED
#define GDK_DEPRECATED_FOR(f)
#define GDK_UNAVAILABLE(maj,min)
#else
#define GDK_DEPRECATED G_DEPRECATED
#define GDK_DEPRECATED_FOR(f) G_DEPRECATED_FOR(f)
#define GDK_UNAVAILABLE(maj,min) G_UNAVAILABLE(maj,min)
#endif

/* XXX: Every new stable minor release bump should add a macro here */

/**
 * GDK_VERSION_3_0:
 *
 * A macro that evaluates to the 3.0 version of GDK, in a format
 * that can be used by the C pre-processor.
 *
 * Since: 3.4
 */
#define GDK_VERSION_3_0         (G_ENCODE_VERSION (3, 0))

/**
 * GDK_VERSION_3_2:
 *
 * A macro that evaluates to the 3.2 version of GDK, in a format
 * that can be used by the C pre-processor.
 *
 * Since: 3.4
 */
#define GDK_VERSION_3_2         (G_ENCODE_VERSION (3, 2))

/**
 * GDK_VERSION_3_4:
 *
 * A macro that evaluates to the 3.4 version of GDK, in a format
 * that can be used by the C pre-processor.
 *
 * Since: 3.4
 */
#define GDK_VERSION_3_4         (G_ENCODE_VERSION (3, 4))

/**
 * GDK_VERSION_3_6:
 *
 * A macro that evaluates to the 3.6 version of GDK, in a format
 * that can be used by the C pre-processor.
 *
 * Since: 3.6
 */
#define GDK_VERSION_3_6         (G_ENCODE_VERSION (3, 6))


/* evaluates to the current stable version; for development cycles,
 * this means the next stable target
 */
#if (GDK_MINOR_VERSION % 2)
#define GDK_VERSION_CUR_STABLE         (G_ENCODE_VERSION (GDK_MAJOR_VERSION, GDK_MINOR_VERSION + 1))
#else
#define GDK_VERSION_CUR_STABLE         (G_ENCODE_VERSION (GDK_MAJOR_VERSION, GDK_MINOR_VERSION))
#endif

/* evaluates to the previous stable version */
#if (GDK_MINOR_VERSION % 2)
#define GDK_VERSION_PREV_STABLE        (G_ENCODE_VERSION (GDK_MAJOR_VERSION, GDK_MINOR_VERSION - 1))
#else
#define GDK_VERSION_PREV_STABLE        (G_ENCODE_VERSION (GDK_MAJOR_VERSION, GDK_MINOR_VERSION - 2))
#endif

/**
 * GDK_VERSION_MIN_REQUIRED:
 *
 * A macro that should be defined by the user prior to including
 * the gdk.h header.
 * The definition should be one of the predefined GDK version
 * macros: %GDK_VERSION_3_0, %GDK_VERSION_3_2,...
 *
 * This macro defines the lower bound for the GDK API to use.
 *
 * If a function has been deprecated in a newer version of GDK,
 * it is possible to use this symbol to avoid the compiler warnings
 * without disabling warning for every deprecated function.
 *
 * Since: 3.4
 */
#ifndef GDK_VERSION_MIN_REQUIRED
# define GDK_VERSION_MIN_REQUIRED      (GDK_VERSION_CUR_STABLE)
#endif

/**
 * GDK_VERSION_MAX_ALLOWED:
 *
 * A macro that should be defined by the user prior to including
 * the gdk.h header.
 * The definition should be one of the predefined GDK version
 * macros: %GDK_VERSION_3_0, %GDK_VERSION_3_2,...
 *
 * This macro defines the upper bound for the GDK API to use.
 *
 * If a function has been introduced in a newer version of GDK,
 * it is possible to use this symbol to get compiler warnings when
 * trying to use that function.
 *
 * Since: 3.4
 */
#ifndef GDK_VERSION_MAX_ALLOWED
# if GDK_VERSION_MIN_REQUIRED > GDK_VERSION_PREV_STABLE
#  define GDK_VERSION_MAX_ALLOWED      GDK_VERSION_MIN_REQUIRED
# else
#  define GDK_VERSION_MAX_ALLOWED      GDK_VERSION_CUR_STABLE
# endif
#endif

/* sanity checks */
#if GDK_VERSION_MAX_ALLOWED < GDK_VERSION_MIN_REQUIRED
#error "GDK_VERSION_MAX_ALLOWED must be >= GDK_VERSION_MIN_REQUIRED"
#endif
#if GDK_VERSION_MIN_REQUIRED < GDK_VERSION_3_0
#error "GDK_VERSION_MIN_REQUIRED must be >= GDK_VERSION_3_0"
#endif

/* XXX: Every new stable minor release should add a set of macros here */

#if GDK_VERSION_MIN_REQUIRED >= GDK_VERSION_3_0
# define GDK_DEPRECATED_IN_3_0                GDK_DEPRECATED
# define GDK_DEPRECATED_IN_3_0_FOR(f)         GDK_DEPRECATED_FOR(f)
#else
# define GDK_DEPRECATED_IN_3_0
# define GDK_DEPRECATED_IN_3_0_FOR(f)
#endif

#if GDK_VERSION_MAX_ALLOWED < GDK_VERSION_3_0
# define GDK_AVAILABLE_IN_3_0                 GDK_UNAVAILABLE(3, 0)
#else
# define GDK_AVAILABLE_IN_3_0
#endif

#if GDK_VERSION_MIN_REQUIRED >= GDK_VERSION_3_2
# define GDK_DEPRECATED_IN_3_2                GDK_DEPRECATED
# define GDK_DEPRECATED_IN_3_2_FOR(f)         GDK_DEPRECATED_FOR(f)
#else
# define GDK_DEPRECATED_IN_3_2
# define GDK_DEPRECATED_IN_3_2_FOR(f)
#endif

#if GDK_VERSION_MAX_ALLOWED < GDK_VERSION_3_2
# define GDK_AVAILABLE_IN_3_2                 GDK_UNAVAILABLE(3, 2)
#else
# define GDK_AVAILABLE_IN_3_2
#endif

#if GDK_VERSION_MIN_REQUIRED >= GDK_VERSION_3_4
# define GDK_DEPRECATED_IN_3_4                GDK_DEPRECATED
# define GDK_DEPRECATED_IN_3_4_FOR(f)         GDK_DEPRECATED_FOR(f)
#else
# define GDK_DEPRECATED_IN_3_4
# define GDK_DEPRECATED_IN_3_4_FOR(f)
#endif

#if GDK_VERSION_MAX_ALLOWED < GDK_VERSION_3_4
# define GDK_AVAILABLE_IN_3_4                 GDK_UNAVAILABLE(3, 4)
#else
# define GDK_AVAILABLE_IN_3_4
#endif

#if GDK_VERSION_MIN_REQUIRED >= GDK_VERSION_3_6
# define GDK_DEPRECATED_IN_3_6                GDK_DEPRECATED
# define GDK_DEPRECATED_IN_3_6_FOR(f)         GDK_DEPRECATED_FOR(f)
#else
# define GDK_DEPRECATED_IN_3_6
# define GDK_DEPRECATED_IN_3_6_FOR(f)
#endif

#if GDK_VERSION_MAX_ALLOWED < GDK_VERSION_3_6
# define GDK_AVAILABLE_IN_3_6                 GDK_UNAVAILABLE(3, 6)
#else
# define GDK_AVAILABLE_IN_3_6
#endif

#endif  /* __GDK_VERSION_MACROS_H__ */
