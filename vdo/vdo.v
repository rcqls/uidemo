import ui

const (
	w_width  = 400
	w_height = 600
	w_title  = 'V DO'
)

struct Task {
mut:
	title string
	done  bool
}

struct State {
pub mut:
	tasks     map[int]Task
	inputs    []string
	last_task int = 1
	input     string
	window    &ui.Window = voidptr(0)
}

fn main() {
	mut app := &State{
		tasks: {
			0: Task{
				title: 'test'
				done: false
			}
			1: Task{
				title: 'test 2'
				done: false
			}
		}
	}

	window := ui.window(
		width: w_width
		height: w_height
		state: app
		title: w_title
		mode: .resizable
		// on_scroll: on_scroll
		children: [
			ui.column(
				margin_: 8
				heights: [ui.stretch, ui.compact]
				children: [
					ui.column(
					id: 'entries_column'
					heights: ui.compact
					spacing: 4
					scrollview: true
					children: tasks(mut app)
				),
					ui.row(
						widths: [ui.stretch, ui.compact]
						spacing: 4
						children: [ui.textbox(text: &app.input, on_enter: on_enter),
							ui.button(text: '+', onclick: btn_add_task),
						]
					),
				]
			),
		]
	)

	app.window = window
	ui.run(window)
}

fn tasks(mut app State) []ui.Widget {
	mut tasks := []ui.Widget{}

	for i, _ in app.tasks {
		tasks << entry(i, mut app)
	}

	return tasks
}

fn entry(task_id int, mut app State) &ui.Stack {
	task := app.tasks[task_id]
	app.inputs << task.title.clone()
	// THIS WEIRDLY DOES NOT WORK:
	// mut tb := ui.textbox(id: "task_tb_$task_id", text: &(app.tasks[task_id].title), on_char: txb_enter_edit)
	// So the introduction of app.inputs
	mut tb := ui.textbox(
		id: 'task_tb_$task_id'
		text: &(app.inputs[app.inputs.len - 1])
		on_char: txb_enter_edit
	)
	tb.z_index = ui.z_index_hidden
	row := ui.row(
		id: 'task_row_$task_id'
		widths: [ui.compact, ui.stretch, ui.stretch, ui.compact]
		spacing: 4
		children: [
			ui.checkbox(id: 'task_cb_$task_id', checked: task.done, on_click: cb_task),
			ui.label(id: 'task_lab_$task_id', text: task.title.clone()),
			tb,
			ui.button(id: 'task_btn_$task_id', text: 'E', onclick: btn_task),
		]
	)
	return row
}

fn task_entry_index(column &ui.Stack, task_id int) int {
	return column.child_index_by_id('task_row_$task_id')
}

fn cb_task(cb &ui.CheckBox, mut app State) {
	task_id := cb.id.split('_').last().int()
	app.tasks[task_id].done = cb.checked
}

fn btn_add_task(mut app State, btn &ui.Button) {
	add_task(mut app, app.window)
}

fn btn_task(mut app State, mut btn ui.Button) {
	task_id := btn.id.split('_').last().int()
	win := btn.ui.window

	mut column := win.stack('entries_column')
	mut lab := win.label('task_lab_$task_id')
	println('btn_task($btn.text) $task_id lab=<$lab.text>')
	mut tb := win.textbox('task_tb_$task_id')

	println('tb=<${*tb.text}>')
	task_index := task_entry_index(column, task_id)

	//
	println(' at $task_index')

	if btn.text == 'E' {
		if task_index > -1 {
			ui.set_depth(mut lab, ui.z_index_hidden)
			ui.set_depth(mut tb, 0)
			btn.text = 'D'
			win.update_layout()
			tb.focus()
		}
	} else {
		if task_index > -1 {
			column.remove(at: task_index)
			app.tasks.delete(task_index)
		}
	}
}

fn txb_enter_edit(mut app State, mut tb ui.TextBox, keycode u32) {
	if keycode == 13 {
		// println("on_enter: $app.tasks")
		task_id := tb.id.split('_').last().int()
		win := tb.ui.window
		mut lab := win.label('task_lab_$task_id')
		mut btn := win.button('task_btn_$task_id')

		ui.set_depth(mut lab, 0)
		ui.set_depth(mut tb, ui.z_index_hidden)
		lab.text = *tb.text
		btn.text = 'E'
		win.update_layout()
	}
}

fn add_task(mut app State, window &ui.Window) {
	app.last_task += 1
	new_task := Task{
		title: app.input.clone()
		done: false
	}
	app.tasks[app.last_task] = new_task
	app.input = ''

	// println("add $app.last_task $app.tasks")

	mut column := window.stack('entries_column')

	column.add(
		child: entry(app.last_task, mut app)
	)
}

fn on_enter(s string, mut app State) {
	add_task(mut app, app.window)
	println(app.tasks)
}
