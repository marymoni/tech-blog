library(rgl)

plot_func_3D = function(func, from, to, by) {
	x = seq(from, to, by)
	y = seq(from, to, by)
	z = outer(x, y, func)
	persp3d(x, y, z, col = "red", alpha = 0.7)
}

plot_func_3D(eggholder, -1, 1, 0.1)
plot_func_3D(himmelblau, -1, 1, 0.1)
plot_func_3D(cross_in_tray, -5, 5, 0.1)
plot_func_3D(styblinski_tang, -5, 5, 0.1)

plot_func_3D(sphere, -1, 1, 0.1)
plot_func_3D(rosenbrock, -2, 2, 0.1)
plot_func_3D(rastrigin, -1, 1, 0.1)
plot_func_3D(styblinski_tang, -5, 5, 0.1)