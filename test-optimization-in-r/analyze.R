lf = list.files()
res.summary = data.frame(func_name = character(0), method_name = character(0), variable_count = numeric(0), max_iter = numeric(0), value = numeric(0), error = numeric(0), time = numeric(0))

for(f in lf) {
	res = readRDS(f)
	func_name = strsplit(f, "\\.")[[1]][1]
	method_name = strsplit(f, "\\.")[[1]][2]
	variable_count=res$variable_count
	if (method_name == "rbga") {
		value = res$best[which.min(res$best)]
	} else {
		value = res$value
	}
	if (func_name == "styblinski_tang") {
		error = abs(value - (-39.16599)*variable_count)
	} else {
		error = abs(value)
	}
	res.item = data.frame(func_name = func_name, method_name = method_name, variable_count = variable_count, max_iter = res$max_iter, value = value, error = error, time = as.numeric(res$time))
	res.summary <<- rbind(res.summary, res.item)
}
