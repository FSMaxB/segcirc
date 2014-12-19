#include "pebble.h"

//global variables
static Window* window;
static TextLayer *time_layer;	//to show the time
static TextLayer *date_layer;	//to show the date
static TextLayer *wday_layer;	//to show the current weekday

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
static char wday_text[] = "Thu";

//global state
struct state {
	bool connected;
};
static struct state state;

//tick handlers
static void handle_second_tick(struct tm* tick_time, TimeUnits units_changed) {
}

static void handle_minute_tick(struct tm* tick_time, TimeUnits units_changed) {
	//get current time string
	if(clock_is_24h_style() == true) {
		strftime(time_text, sizeof(time_text), "%H:%M", tick_time);
	} else {
		strftime(time_text, sizeof(time_text), "%I:%M", tick_time);
	}

	text_layer_set_text(time_layer, time_text);
}

static void handle_hour_tick(struct tm* tick_time, TimeUnits units_changed) {
	//set current date string
	strftime(date_text, sizeof(date_text), "%x", tick_time);
	text_layer_set_text(date_layer, date_text);

	//set current weekday string
	strftime(wday_text, sizeof(wday_text), "%a", tick_time);
	text_layer_set_text(wday_layer, wday_text);
}

static void init() {
	//initialise global state
	state.connected = true;

	//create main window
	window = window_create();
	window_stack_push(window, true);
	window_set_background_color(window, GColorBlack);

	//create fonts
	time_font = fonts_load_custom_font(resource_get_handle(RESOURCE_ID_FONT_FOURTEEN_SEGMENT_34));
	wday_font = fonts_load_custom_font(resource_get_handle(RESOURCE_ID_FONT_FOURTEEN_SEGMENT_22));
	date_font = fonts_load_custom_font(resource_get_handle(RESOURCE_ID_FONT_FOURTEEN_SEGMENT_14));

	//init bitmaps
	image_no_connection = gbitmap_create_with_resource(RESOURCE_ID_IMAGE_NO_CONNECTION);
	no_connection_layer = bitmap_layer_create(GRect(55, 116, 34, 12));
	bitmap_layer_set_bitmap(no_connection_layer, image_no_connection);

	//init text layers
	time_layer = text_layer_create(GRect(24, 68, 100, 34));
	text_layer_set_text_color(time_layer, GColorWhite);
	text_layer_set_background_color(time_layer, GColorClear);
	text_layer_set_font(time_layer, time_font);
	text_layer_set_text(time_layer, "00:00");

	date_layer = text_layer_create(GRect(38, 100, 70, 14));
	text_layer_set_text_color(date_layer, GColorWhite);
	text_layer_set_background_color(date_layer, GColorClear);
	text_layer_set_font(date_layer, date_font);
	text_layer_set_text(date_layer, "01.01.2000");

	wday_layer = text_layer_create(GRect(57, 42, 29, 22));
	text_layer_set_text_color(wday_layer, GColorWhite);
	text_layer_set_background_color(wday_layer, GColorClear);
	text_layer_set_font(wday_layer, wday_font);
	text_layer_set_text(wday_layer, "Mo");
	

	//add textlayers to root window
	layer_add_child(window_get_root_layer(window), text_layer_get_layer(time_layer));
	layer_add_child(window_get_root_layer(window), text_layer_get_layer(date_layer));
	layer_add_child(window_get_root_layer(window), text_layer_get_layer(wday_layer));
	layer_add_child(window_get_root_layer(window), bitmap_layer_get_layer(no_connection_layer));

	//initialize display
	time_t temp = time(NULL);
	handle_second_tick(localtime(&temp), SECOND_UNIT);
	handle_minute_tick(localtime(&temp), MINUTE_UNIT);
	handle_hour_tick(localtime(&temp), HOUR_UNIT);

	//register handlers
	tick_timer_service_subscribe(SECOND_UNIT, &handle_second_tick);
	tick_timer_service_subscribe(MINUTE_UNIT, &handle_minute_tick);
	tick_timer_service_subscribe(HOUR_UNIT, &handle_hour_tick);
}

static void deinit() {
	//unload fonts
	fonts_unload_custom_font(time_font);
	fonts_unload_custom_font(date_font);
	fonts_unload_custom_font(wday_font);

	//destroy bitmaps
	gbitmap_destroy(image_no_connection);

	//destroy layers
	text_layer_destroy(time_layer);
	text_layer_destroy(date_layer);
	text_layer_destroy(wday_layer);
	bitmap_layer_destroy(no_connection_layer);

	//destroy main window
	window_destroy(window);
}

int main() {
	init();
	app_event_loop();
	deinit();
}
