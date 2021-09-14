import ui
import uicomponent as uic
import gx

struct App {
mut:
	window &ui.Window = 0
	log    string
	text   string = 'il était une fois V ....\nLa vie est belle...'
}

fn main() {
	mut app := &App{}
	mut tb := ui.textbox(
		id: 'tb'
		text: &app.text
		mode: .multiline
		bg_color: gx.yellow
	)
	mut dtw := ui.DrawTextWidget(tb)
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
							dtw: tb
						),
						uic.button_color(
							bg_color: &tb.text_styles.current.color
						)
						uic.button_color(
							bg_color: &tb.bg_color
						)
					])
					tb
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
	c.draw_empty_rect(10, 11, w + 2, h + 2, gx.black)
	c.draw_styled_text(10 + w + 10, 10, 'size: ($w, $h)', 'default')
}
