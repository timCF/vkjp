module.exports =
	error: (mess) -> $.growl.error({ message: mess , duration: 20000})
	warn: (mess) -> $.growl.warning({ message: mess , duration: 20000})
	notice: (mess) -> $.growl.notice({ message: mess , duration: 20000})
	info: (mess) -> $.growl({ message: mess , duration: 20000})
	view_set: (state, path, ev) ->
		if (ev? and ev.target? and ev.target.value?)
			subj = ev.target.value
			Imuta.update_in(state, path, (_) -> subj)
	view_swap: (state, path) ->
		Imuta.update_in(state, path, (bool) -> not(bool))
	view_files: (state, path, ev) ->
		if (ev? and ev.target? and ev.target.files? and (ev.target.files.length > 0))
			Imuta.update_in(state, path, (_) -> [].map.call(ev.target.files, (el) -> el))
	search: (state) ->
		state.data.task.is_running = true
		todo = state.data.search.inputobjects.split("\n")
				.map($.trim)
				.reduce(((acc, el) -> acc[el] = true ; acc), {})
		state.methods.set_default_task()
		@.search_process(state, Object.keys(todo))
	search_process: (state, todo) ->
		console.log(todo)