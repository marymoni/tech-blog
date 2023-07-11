sphere = function(x, y) {
	x^2 + y^2
}

sphere.md = function(x) {
	sum(x*x)
}

rosenbrock = function(x, y) {
	(1-x)^2+100*(y-x^2)^2
}

rosenbrock.md = function(x) {
	n = length(x)
	sum( (x[1:(n-1)]-1)^2 + 100*(x[2:n] - x[1:(n-1)]^2)^2 )
}

rastrigin = function(x, y) {
	20 + x^2 - 10*cos(2*pi*x) + y^2 - 10*cos(2*pi*y)
}

rastrigin.md = function(x) {
	length(x)*10 + sum(x^2 - 10*cos(2*pi*x))
}

styblinski_tang = function(x, y) {
	0.5*(x^4 - 16*x^2 + 5*x + y^4 - 16*y^2 + 5*y)
}

styblinski_tang.md = function(x) {
	0.5*sum(x^4 - 16*x^2 + 5*x)
}

himmelblau = function(x, y) {
	(x^2 + y - 11)^2 + (x + y^2 - 7)^2
}

cross_in_tray = function(x, y) {
	-0.0001*(1 + abs(sin(x)*sin(y)*exp(abs(100 - sqrt(x^2+y^2)/pi))))^0.1
}

eggholder = function(x, y) {
	-(y+47)*sin(sqrt(abs(y+x/2+47))) - x*sin(sqrt(abs(x-y-47)))
}
