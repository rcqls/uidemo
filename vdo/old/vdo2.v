import ui

const (
	w_width  = 400
	w_height = 600
	w_title  = 'V DO'
)

struct Task {
mut:
	id	  int
	title string
	done  bool
}

struct State {
mut:
	tasks      []Task
	last_task  int = 1
	input      string
	edit_input string
	edit_index int        = -1
	window     &ui.Window = voidptr(0)

	edit bool // workaround prevent double call of click handler
}

fn main() {
	mut app := &State{
		tasks: [
			Task{
				id: 0
				title: 'test'
				done: false
			},
			Task{
				id: 1
				title: 'test 2'
				done: false
			},
		]
	}

	window := ui.window(
		width: w_width
		height: w_height
		state: app
		title: w_title
		mode: .resizable
		// on_scroll: on_scroll
	children: [
		ui.column(margin_: 8, heights: [ui.stretch, ui.compact], children: [
			ui.column(id: "entries_column", heights: ui.compact, spacing: 4,  scrollview: true, children: tasks(app)),
			ui.row(widths: [ui.stretch, ui.compact], spacing: 4, children: [
				ui.textbox(text: &app.input, on_enter: on_enter),
				ui.button(text: '+', onclick: btn_add_task),
			]),
		]),
	])

	app.window = window
	ui.run(window)
}

fn tasks(app &State) []ui.Widget {
	mut tasks := []ui.Widget{}

	for task in app.tasks {
		tasks << entry(task)
	}

	return tasks
}

fn entry(task Task) &ui.Stack {
	return ui.row(id: "task_show_row_$task.id", widths: [ui.compact, ui.stretch, ui.compact], spacing: 4, children: [
		ui.checkbox(id: "task_show_cb_$task.id", checked: task.done, on_click: cb_task),
		ui.label(id: "task_show_lab_$task.id", text: task.title.clone()),
		ui.button(id: "task_show_btn_$task.id", text: 'E', onclick: btn_edit_task),
	])
}

fn edit_entry(mut app State, task_index int) &ui.Stack {
	task_id := app.tasks[task_index].id
	titles := app.tasks.map(it.title)
	println("edit_entry tasks titles: $titles")
	title := app.tasks[task_index].title
	println("add edit_entry $task_id at $task_index title: <$title>")
	return ui.row(id: "task_edit_row_$task_id", widths: [ui.stretch, ui.compact], spacing: 4, children: [
		ui.textbox(id: "task_edit_tb_$task_id", text: &app.tasks[task_index].title, on_char: txb_enter_edit, is_focused: true),
		ui.button(id: "task_edit_btn_$task_id", text: 'D', onclick: btn_remove_task),
	])
}

fn entries_column(w &ui.Window) ?&ui.Stack {
	s := w.child(0)
	if mut s is ui.Stack {
		return s
	}

	return error('Cannot find entries column')
}

fn cb_task(cb &ui.CheckBox, mut app State) {
	task_id := cb.id.split("_").last().int()
	win := cb.ui.window
	
	mut column := win.stack("entries_column")

	index := column.child_index_by_id("task_show_row_$task_id")
	app.tasks[index].done = cb.checked
}

fn btn_add_task(mut app State, btn &ui.Button) {
	add_task(mut app, btn.ui.window)
}

fn btn_edit_task(mut app State, btn &ui.Button) {
	task_id := btn.id.split("_").last().int()
	win := btn.ui.window
	
	mut column := win.stack("entries_column")

	index := column.child_index_by_id("task_show_row_$task_id")

	println("btn_edit_task $task_id at $index")

	if index > -1 {
		column.remove(at: index)
		column.add(at: index, child: edit_entry(mut app, index))
		app.edit = true
	}
}

fn btn_remove_task(mut app State, btn &ui.Button) {
	if app.edit {
		app.edit = false
		return
	}
	
	task_id := btn.id.split("_").last().int()

	win := btn.ui.window
	mut column := win.stack("entries_column")

	index := column.child_index_by_id("task_edit_row_$task_id")
	println("btn_remove_task $task_id task at $index")
	if index > -1 {
		column.remove(at: index)
		app.tasks.delete(index)
	}
}

fn txb_enter_edit(mut app State, tb &ui.TextBox, keycode u32) {

	if keycode == 13 {
		titles := app.tasks.map(it.title)
		println("tasks titles: $titles")
		println("on_enter: $app.tasks")
		task_id := tb.id.split("_").last().int()
		win := tb.ui.window
		mut column := win.stack("entries_column")

		index := column.child_index_by_id("task_edit_row_$task_id")

		if index > -1 {
			column.remove(at: index)
			column.add(
				at: index
				child: entry(app.tasks[index])
			)
		}
	}

}

fn add_task(mut app State, window &ui.Window) {
	app.last_task += 1
	new_task := Task{
		id: app.last_task
		title: app.input
		done: false
	}
	app.tasks << new_task
	app.input = ''

	mut column := window.stack("entries_column")

	column.add(
		child: entry(new_task)
	)

	// window.update_layout()
}

fn on_scroll(e ui.ScrollEvent, w &ui.Window) {
	mut s := entries_column(w) or {
		println(err)
		return
	}

	mut content_height := 0

	for mut c in s.children {
		_, h := c.size()
		content_height += h
	}

	if s.real_height - content_height >= 0 {
		s.margins.top = 0
	} else {
		s.margins.top = f32_max(f32_min(0, s.margins.top - f32(e.y)), s.real_height - content_height)
	}

	w.update_layout()
}

fn on_enter(_ string, mut app State) {
	add_task(mut app, app.window)
}
