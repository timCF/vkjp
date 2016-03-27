module.exports = (state, utils) ->
	state.data = {}
	state.methods = {}
	state.methods.set_default_search = () ->
		state.data.search = {
			object: "users"
			subject: "audio" # || "video"
			field: "artist" # || "title"
			algorithm: "substring" # || "direct"
			inputsubjects: ""
			inputobjects: ""
		}
	state.methods.set_default_task = () ->
		state.data.task = {
			is_running: false
			# for progress-bar
			n_total: 1
			n_ok: 0
			n_mismatch: 0
			n_error: 0
			# rest not handled items
			tail: []
			# intermediate result
			acc: []
		}
	state.methods.set_default_search()
	state.methods.set_default_task()
