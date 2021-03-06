/*
 * 	Watchface for the pebble smartwatch.
 *  Copyright (C) 2014  Max Bruckner (FSMaxB)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <pebble.h>

#define DATE_FORMAT "%d.%m.%Y"

//ui elements
static Window* window;
static Layer* window_layer;
static Layer* square_layer;
static TextLayer* time_layer;	//to show the time
static TextLayer* date_layer;	//to show the date
static TextLayer* wday_layer;	//to show the current weekday
static Layer* battery_layer;	//to show current battery charge

//fonts
static GFont time_font;
static GFont wday_font;
static GFont date_font;

//images
static GBitmap* image_no_connection;
static BitmapLayer* no_connection_layer;

//text buffers
static char time_text[] = "00:00";
static char date_text[] = "01.01.2014";

//bounding rects
static GRect window_bounds;
static GRect square_bounds;
static GRect time_bounds;
static GRect date_bounds;
static GRect wday_bounds;
static GRect battery_bounds;
static GRect no_connection_bounds;

//radius
static uint16_t inner_radius, middle_radius, outer_radius;

//center point
static GPoint center_point;

//hour hand
static GPathInfo initial_hour_hand_points;
static GPathInfo hour_hand_points;
static GPath* hour_hand;

//weekday strings beginning with sunday ( see tm struct tm_wday )
const char* weekday_strings[7] = { "So", "Mo", "Di", "Mi", "Do", "Fr", "Sa" };

//global state
struct state {
	bool connected;
	struct tm current_time;
	BatteryChargeState battery;
};
static struct state state;

//helper functions for drawing
//get the coordinates of a point on a circle with a certain radius and at a certain angle
static GPoint get_point_at_exact_angle( GPoint middle, uint32_t radius, int16_t angle /*0-TRIG_MAX_ANGLE*/) {
	middle.x += (sin_lookup(angle)*radius / TRIG_MAX_RATIO);
	middle.y += (-cos_lookup(angle)*radius / TRIG_MAX_RATIO);
	return middle;
}

static GPoint get_point_at_angle(GPoint middle, uint32_t radius, int16_t angle /*0-59*/) {
	return get_point_at_exact_angle( middle, radius, TRIG_MAX_ANGLE * angle / 60 );
}

static void helper_grect_center_x( GRect* rect, GRect* outer_rect ) {
	int16_t y = rect->origin.y;
	grect_align( rect, outer_rect, GAlignCenter, true );
	rect->origin.y = y;
}

static void helper_grect_center_y( GRect* rect, GRect* outer_rect ) {
	int16_t x = rect->origin.x;
	grect_align( rect, outer_rect, GAlignCenter, true );
	rect->origin.x = x;
}

//rotate Points around the origin (0,0)
static GPoint helper_rotate_point( GPoint point, int32_t angle ) {
		//(cos(α) x(A) - sin(α) y(A), sin(α) x(A) + cos(α) y(A)) //Entspricht Multiplikation mit Drehmatrix
		GPoint new_point;
		new_point.x = (cos_lookup(angle)*point.x - sin_lookup(angle)*point.y)/TRIG_MAX_RATIO;
		new_point.y = (sin_lookup(angle)*point.x + cos_lookup(angle)*point.y)/TRIG_MAX_RATIO;
		return new_point;
}

//do all the drawing
static void draw_hour_circles( GContext* context ) {
	uint16_t hour;
	GPoint point;
	for( hour = 0; hour < 12; hour++ ) {
		if( hour != state.current_time.tm_hour % 12 ) { //don't draw circle under hour hand
			point = get_point_at_angle( center_point, outer_radius, 5*hour );
			graphics_fill_circle( context, point, 2 );
		}
	}
}

static void draw_minute_circles( GContext* context ) {
	uint16_t minute;
	GPoint point;
	for( minute = 0; minute <= state.current_time.tm_min; minute++ ) {
		if( minute != (state.current_time.tm_hour % 12)*5 ) { //don't draw circle under hour hand
			point = get_point_at_angle( center_point, middle_radius, minute );
			graphics_fill_circle( context, point, 2 );
		}
	}

	for( minute = state.current_time.tm_min + 1; minute < 60; minute++ ) {
		if( minute != (state.current_time.tm_hour % 12)*5 ) { //don't draw circle under hour hand
			point = get_point_at_angle( center_point, middle_radius, minute );
			graphics_draw_circle( context, point, 2 );
		}
	}
}

static void draw_hour_hand( GContext* context ) {
	gpath_draw_filled( context, hour_hand );
}

static void draw(Layer* layer, GContext* context) {
	graphics_context_set_stroke_color( context, GColorWhite);
	graphics_context_set_fill_color( context, GColorWhite );

	draw_hour_circles(context);
	draw_minute_circles(context);
	draw_hour_hand(context);
}

static void draw_battery( Layer* layer, GContext* context ) {
	graphics_context_set_stroke_color( context, GColorWhite );
	graphics_context_set_fill_color( context, GColorWhite );

	GRect bounds = layer_get_bounds(layer);
	graphics_draw_rect( context,  bounds );
	uint32_t width = bounds.size.w*state.battery.charge_percent / 100;
	graphics_fill_rect( context, GRect(0, 0, width, bounds.size.h), 0, GCornerNone );
}

//tick handlers
static void handle_second_tick(struct tm* tick_time) {
	state.current_time = *tick_time;
}

static void handle_minute_tick(struct tm* tick_time) {
	//get current time string
	if(clock_is_24h_style() == true) {
		strftime(time_text, sizeof(time_text), "%H:%M", tick_time);
	} else {
		strftime(time_text, sizeof(time_text), "%I:%M", tick_time);
	}

	text_layer_set_text(time_layer, time_text);
	layer_mark_dirty(square_layer);
}

static void handle_hour_tick(struct tm* tick_time) {
	//set current date string
	strftime(date_text, sizeof(date_text), DATE_FORMAT, tick_time);
	text_layer_set_text(date_layer, date_text);

	//set current weekday string
	text_layer_set_text(wday_layer, weekday_strings[tick_time->tm_wday]);
	layer_mark_dirty( square_layer );

	int32_t hour_angle = (TRIG_MAX_ANGLE*(state.current_time.tm_hour%12))/12;
	uint16_t i;
	for( i = 0; i < hour_hand->num_points; i++ ) {
		hour_hand->points[i] =
			helper_rotate_point( initial_hour_hand_points.points[i], hour_angle );
	}
}

static void handle_ticks( struct tm* tick_time, TimeUnits units_changed ) {
	if( units_changed & SECOND_UNIT ) {
		handle_second_tick(tick_time);
	}

	if( units_changed & MINUTE_UNIT ) {
		handle_minute_tick(tick_time);
	}

	if( units_changed & HOUR_UNIT ) {
		handle_hour_tick(tick_time);
	}
}

static void handle_battery_state( BatteryChargeState battery_state ) {
	state.battery = battery_state;
	layer_mark_dirty( battery_layer );
}

static void handle_bluetooth( bool connected ) {
	state.connected = connected;
	layer_set_hidden( bitmap_layer_get_layer(no_connection_layer), connected );
}

static void init() {
	//initialise global state
	state.connected = true;
	state.battery = battery_state_service_peek();

	//create main window
	window = window_create();
	window_stack_push(window, true);
	window_set_background_color(window, GColorBlack);
	window_layer = window_get_root_layer(window);

	window_bounds = layer_get_bounds(window_layer);

	//create fonts
	time_font = fonts_load_custom_font(resource_get_handle(RESOURCE_ID_FONT_FOURTEEN_SEGMENT_38));
	wday_font = fonts_load_custom_font(resource_get_handle(RESOURCE_ID_FONT_FOURTEEN_SEGMENT_24));
	date_font = fonts_load_custom_font(resource_get_handle(RESOURCE_ID_FONT_FOURTEEN_SEGMENT_14));

	//init layer
	square_bounds = GRect(0, 0, window_bounds.size.w, window_bounds.size.w + 1 );
	grect_align( &square_bounds, &window_bounds, GAlignCenter, true );
	square_layer = layer_create(square_bounds);
	layer_set_update_proc(square_layer, draw);
	square_bounds = layer_get_bounds(square_layer);

	//init text layers
	time_bounds = GRect(0, 0, 120, 38);
	grect_align( &time_bounds, &square_bounds, GAlignCenter, true );
	time_bounds.origin.y -= 5;
	time_layer = text_layer_create(time_bounds);
	text_layer_set_text_color(time_layer, GColorWhite);
	text_layer_set_background_color(time_layer, GColorClear);
	text_layer_set_font(time_layer, time_font);
	text_layer_set_text_alignment(time_layer, GTextAlignmentCenter);

	date_bounds = GRect(0, 0, 85, 14);
	date_bounds.origin = time_bounds.origin;
	helper_grect_center_x( &date_bounds, &square_bounds );
	date_bounds.origin.y += time_bounds.size.h;
	date_layer = text_layer_create(date_bounds);
	text_layer_set_text_color(date_layer, GColorWhite);
	text_layer_set_background_color(date_layer, GColorClear);
	text_layer_set_font(date_layer, date_font);
	text_layer_set_text_alignment(date_layer, GTextAlignmentCenter);

	//battery indicator
	battery_bounds = GRect( 0, 0, 70, 4 );
	helper_grect_center_x( &battery_bounds, &square_bounds );
	battery_bounds.origin.y = time_bounds.origin.y + 2;
	//battery_bounds.origin.y -= battery_bounds.size.h;
	battery_layer = layer_create(battery_bounds);
	layer_set_update_proc( battery_layer, draw_battery );

	wday_bounds = GRect(0, 0, 30, 24);
	wday_bounds.origin = battery_bounds.origin;
	helper_grect_center_x( &wday_bounds, &square_bounds );
	wday_bounds.origin.y -= wday_bounds.size.h + 3;
	wday_layer = text_layer_create(wday_bounds);
	text_layer_set_text_color(wday_layer, GColorWhite);
	text_layer_set_background_color(wday_layer, GColorClear);
	text_layer_set_font(wday_layer, wday_font);
	text_layer_set_text_alignment(wday_layer, GTextAlignmentCenter);


	//init bitmaps
	image_no_connection = gbitmap_create_with_resource(RESOURCE_ID_IMAGE_NO_CONNECTION);
	no_connection_bounds = GRect(0, 0, 34, 12);
	no_connection_bounds.origin = date_bounds.origin;
	helper_grect_center_x( &no_connection_bounds, &square_bounds );
	no_connection_bounds.origin.y += date_bounds.size.h + 3;
	no_connection_layer = bitmap_layer_create(no_connection_bounds);
	bitmap_layer_set_bitmap(no_connection_layer, image_no_connection);
	bitmap_layer_set_alignment(no_connection_layer, GAlignCenter);
	state.connected = bluetooth_connection_service_peek();	//get current connection status
	layer_set_hidden( bitmap_layer_get_layer(no_connection_layer), state.connected );

	//add textlayers to root window
	layer_add_child(square_layer, text_layer_get_layer(time_layer));
	layer_add_child(square_layer, text_layer_get_layer(date_layer));
	layer_add_child(square_layer, text_layer_get_layer(wday_layer));
	layer_add_child(square_layer, bitmap_layer_get_layer(no_connection_layer));
	layer_add_child(square_layer, battery_layer);
	layer_add_child(window_layer, square_layer);

	//set radius
	outer_radius = square_bounds.size.w / 2 - 2;
	middle_radius = outer_radius - 7;
	inner_radius = outer_radius - 5;

	//set center point
	center_point = grect_center_point( &square_bounds );
	center_point.x -= 1;

	//set hour hand points
	initial_hour_hand_points.num_points = 4;
	initial_hour_hand_points.points = ( GPoint [] ) {
		{ -3, -(outer_radius + 1) },
		{  3, -(outer_radius + 1) },
		{  3, -(middle_radius - 3) },
		{ -3, -(middle_radius - 3) }
	};
	//copy initial_hour_hand_points to hour_hand_points
	hour_hand_points.num_points = initial_hour_hand_points.num_points;
	hour_hand_points.points = ( GPoint[] ) {
		{ initial_hour_hand_points.points[0].x, initial_hour_hand_points.points[0].y },
		{ initial_hour_hand_points.points[1].x, initial_hour_hand_points.points[1].y },
		{ initial_hour_hand_points.points[2].x, initial_hour_hand_points.points[2].y },
		{ initial_hour_hand_points.points[3].x, initial_hour_hand_points.points[3].y }
	};
	hour_hand = gpath_create(&hour_hand_points);
	gpath_move_to( hour_hand, center_point );

	//initialize display
	time_t temp = time(NULL);
	handle_second_tick(localtime(&temp));
	handle_minute_tick(localtime(&temp));
	handle_hour_tick(localtime(&temp));
	handle_battery_state(state.battery);

	//register handlers
	tick_timer_service_subscribe(/*SECOND_UNIT|*/MINUTE_UNIT|HOUR_UNIT, &handle_ticks);
	battery_state_service_subscribe(handle_battery_state);
	bluetooth_connection_service_subscribe( handle_bluetooth );
}

static void deinit() {
	//unload fonts
	fonts_unload_custom_font(time_font);
	fonts_unload_custom_font(date_font);
	fonts_unload_custom_font(wday_font);

	//destroy bitmaps
	gbitmap_destroy(image_no_connection);

	//destroy layers
	layer_destroy(square_layer);
	text_layer_destroy(time_layer);
	text_layer_destroy(date_layer);
	text_layer_destroy(wday_layer);
	layer_destroy(battery_layer);
	bitmap_layer_destroy(no_connection_layer);

	gpath_destroy( hour_hand );

	//unsubscribe handlers
	battery_state_service_unsubscribe();
	tick_timer_service_unsubscribe();
	bluetooth_connection_service_unsubscribe();

	//destroy main window
	window_destroy(window);
}

int main() {
	init();
	app_event_loop();
	deinit();
}
