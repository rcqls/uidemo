import ui
import uicomponent as uic
import gx

struct App {
mut:
	window &ui.Window = 0
	log    string
	text   string = 'il était une fois V ....'
}

fn main() {
	mut app := &App{}
	mut c := ui.canvas_plus(
		id: 'c'
		on_draw: on_draw
		bg_color: gx.yellow
	)
	mut dtw := ui.DrawTextWidget(c)
	dtw.update_text_style(size: 30)
	mut window := ui.window(
		state: app
		mode: .resizable
		width: 800
		height: 600
		children: [
			ui.column(
				margin_: 10
				heights: [20.0, ui.stretch]
				spacing: 10
				children: [ui.row(
					widths: ui.compact
					spacing: 10
					children: [uic.button_font(
							text: 'font'
							dtw: c
						),
						uic.button_color(
							bg_color: &c.text_styles.current.color
						)
						uic.button_color(
							bg_color: &c.bg_color
						)
					])
					ui.column(
						children: [
							ui.textbox(
								id: 'font'
								text_size: 20
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
	uic.colorbox_add(mut window)
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
