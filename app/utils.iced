module.exports =
	error: (mess) -> $.growl.error({ message: mess , duration: 700})
	warn: (mess) -> $.growl.warning({ message: mess , duration: 700})
	notice: (mess) -> $.growl.notice({ message: mess , duration: 700})
	info: (mess) -> $.growl({ message: mess , duration: 700})
	view_set: (state, path, ev) ->
		if (ev? and ev.target? and ev.target.value?)
			subj = ev.target.value
			Imuta.update_in(state, path, (_) -> subj)
	view_swap: (state, path) ->
		Imuta.update_in(state, path, (bool) -> not(bool))
	view_files: (state, path, ev) ->
		if (ev? and ev.target? and ev.target.files? and (ev.target.files.length > 0))
			Imuta.update_in(state, path, (_) -> [].map.call(ev.target.files, (el) -> el))
	string2list: (str) ->
		todo = str.split("\n")
				.map($.trim)
				.filter((el) -> el != "")
				.reduce(((acc, el) -> acc[el] = true ; acc), {})
		Object.keys(todo)
	search: (state) ->
		state.methods.set_default_task()
		state.data.task.is_running = true
		state.data.search.inputsubjectslst = @.string2list(state.data.search.inputsubjects).map((el) -> el.toUpperCase())
		@.search_process(state, @.string2list(state.data.search.inputobjects))
	search_process: (state, lst) ->
		if (lst.length != 0)
			cmd = lst.splice(0,25).map((el) -> "API."+state.data.search.subject+".get({owner_id: "+el+", need_user: 1})").join(",")
			@.search_process_execute(state, lst, "return ["+cmd+"];")
		else
			if (state.data.task.acc.length != 0) then download(state.data.task.acc.join("\r\n"), Date()+".txt", "text/plain") else @.error("empty objects list")
			state.methods.set_default_task()
	search_process_execute: (state, lst, code) ->
		state.data.task.tail = lst
		await VK.api("execute", {code: code}, defer apians)
		if Imuta.is_map(apians) and Imuta.is_list(apians.response)
			apians.response.forEach((el) ->
				if Imuta.is_list(el.items)
					[{id: uid}, audio...] = el.items
					if uid
						switch state.data.search.algorithm
							when "substring"
								if state.data.search.inputsubjectslst.some((ss) -> el.items.some((el) -> el[state.data.search.field].toUpperCase().indexOf(ss) != -1))
									state.data.task.n_ok++
									state.data.task.acc.push(uid)
								else
									state.data.task.n_mismatch++
							when "direct"
								if state.data.search.inputsubjectslst.some((ss) -> el.items.some((el) -> el[state.data.search.field].toUpperCase() == ss))
									state.data.task.n_ok++
									state.data.task.acc.push(uid)
								else
									state.data.task.n_mismatch++
					else
						console.log(el)
						@.error("WRONG API ANS ELEMENT "+JSON.stringify(el))
						state.data.task.n_error++
				else
					state.data.task.n_error++)
			setTimeout((() -> search_process(state, lst)), 1500 + Math.random * 1500)
		else
			console.log(apians)
			@.error("WRONG API ANSWER "+JSON.stringify(apians))
			setTimeout((() -> search_process_execute(state, lst, code)), 5000 + Math.random * 5000)
