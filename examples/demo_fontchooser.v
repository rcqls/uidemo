import ui
import uicomponent as uic
// import gx
// import os

struct App {
mut:
	window &ui.Window = 0
	log    string
	text   string = 'il était une fois V ....'
}

fn main() {
	mut app := &App{}
	c := ui.canvas_plus(
		id: 'c'
		height: 200
		on_draw: on_draw
	)
	mut window := ui.window(
		state: app
		mode: .resizable
		height: 240
		children: [
			ui.row(
				widths: [ui.compact, ui.stretch]
				heights: [ui.compact, ui.stretch]
				children: [uic.button_font(
					text: 'font'
					dtw: c
				),
					ui.column(
						children: [
							ui.textbox(
								id: 'font'
								text: &app.text
							),
							c,
						]
					),
				]
			),
		]
	)
	app.window = window
	uic.fontchooser_add(mut window)
	ui.run(app.window)
}

fn on_draw(c &ui.CanvasLayout, app &App) {
	mut dtw := ui.DrawTextWidget(c)
	dtw.load_current_style()
	c.draw_text(10, 10, app.text)
	w, h := dtw.text_size(app.text)
	c.draw_empty_rect(10, 11, w + 2, h + 2)
	c.draw_styled_text(10 + w + 10, 10, 'size: ($w, $h)', 'default')
}
