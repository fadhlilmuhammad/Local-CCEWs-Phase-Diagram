; Author: Dr. Sandro Lubis (Jan 2020)
;         Local equatorial wave phase diagram
;         Lubis, SW, Respati, MR. Impacts of convectively coupled
;         equatorial waves on rainfall extremes in Java, Indonesia.
;         Int J Climatol. 2021; 41: 2418– 2440
; Contact: slubis.geomar@gmail.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "wave_phase_background.ncl"

begin

dir = "dataout/"
wave_name = "kelvin"; input variable (kelvin, er, mrg)

date_start = 19961111; input variable (yyyymmdd)
date_end = 19970112; input variable (yyyymmdd)


central_lon = 130
f = addfile(dir+"waves.northAU_kelvineof.nc", "r")

time = f->time

wave = f->$wave_name$

print("Calculating temporal tendency...")

d_wave = center_finite_diff_n(wave, 1, False, 0, 0)
copy_VarCoords(wave, d_wave)

print("Standardizing...")

wave_std = wave / stddev(wave)
copy_VarCoords(wave, wave_std)

d_wave_std = d_wave / stddev(d_wave)
copy_VarCoords(d_wave, d_wave_std)

print("Tracking phases...")

x = wave_std(time|:, {lon|central_lon})
y = d_wave_std(time|:, {lon|central_lon})

r = sqrt(x ^ 2 + y ^ 2)
theta = atan2(y, x)

pi = 4.0 * atan(1.0)
angle = 22.5 * pi / 180.0

date = cd_calendar(time, -2)
date!0 = "date"
date&date = date

phase = new(dimsizes(time), integer, -999)
phase!0 = "date"
phase&date = date

do t = 0, (dimsizes(time) - 1)
	if (r(t).le.1) then
		phase(t) = 0
	else
		if (theta(t).le.(1.0 * angle) .and. theta(t).gt.(-1.0 * angle)) then
			phase(t) = 1
		else if (theta(t).le.(-1.0 * angle) .and. theta(t).gt.(-3.0 * angle)) then
			phase(t) = 2
		else if (theta(t).le.(-3.0 * angle) .and. theta(t).gt.(-5.0 * angle)) then
			phase(t) = 3
		else if (theta(t).le.(-5.0 * angle) .and. theta(t).gt.(-7.0 * angle)) then
			phase(t) = 4
		else if (theta(t).le.(-7.0 * angle) .or. theta(t).gt.(7.0 * angle)) then
			phase(t) = 5
		else if (theta(t).le.(7.0 * angle) .and. theta(t).gt.(5.0 * angle)) then
			phase(t) = 6
		else if (theta(t).le.(5.0 * angle) .and. theta(t).gt.(3.0 * angle)) then
			phase(t) = 7
		else if (theta(t).le.(3.0 * angle) .and. theta(t).gt.(1.0 * angle)) then
			phase(t) = 8
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
	end if
end do

print("Plotting...")

time_start = ind(date.eq.date_start)
time_end = ind(date.eq.date_end)

n_time = dimsizes(time(time_start:time_end))

wks = gsn_open_wks("pdf", "local_wave_phase_" + wave_name)

plot = wave_phase_background(wks, True)

resLine = True

resLine@gsLineThicknessF = 2.0
resLine@gsLineDashPattern = 2
resLine@gsLineColor = "black"

resMarker = True

cmap = read_colormap_file("cmp_b2r")

x_plot = x(time|time_start:time_end)
y_plot = y(time|time_start:time_end)

line = new((n_time - 1), graphic)
border = new(n_time, graphic)
marker = new(n_time, graphic)

do i = 0, (n_time - 1)
	if (i.lt.(n_time - 1)) then
		line(i) = gsn_add_polyline(wks, plot, (/x_plot(i), x_plot(i + 1)/), (/y_plot(i), y_plot(i + 1)/), resLine)
	end if

	resMarker@gsMarkerIndex = 4
	resMarker@gsMarkerSizeF = 0.015
	resMarker@gsMarkerColor = "black"
	resMarker@gsMarkerThicknessF = 5.0

	border(i) = gsn_add_polymarker(wks, plot, x_plot(i), y_plot(i), resMarker)

	delete(resMarker@gsMarkerColor)
	delete(resMarker@gsMarkerThicknessF)

	resMarker@gsMarkerIndex = 16
	resMarker@gsMarkerSizeF = 0.0125

	if (x_plot(i).le.(-4.0)) then
		resMarker@gsMarkerColor = cmap(2, :)
	end if
	if (x_plot(i).le.(-3.5) .and. x_plot(i).gt.(-4.0)) then
		resMarker@gsMarkerColor = cmap(6, :)
	end if
	if (x_plot(i).le.(-3.0) .and. x_plot(i).gt.(-3.5)) then
		resMarker@gsMarkerColor = cmap(10, :)
	end if
	if (x_plot(i).le.(-2.5) .and. x_plot(i).gt.(-3.0)) then
		resMarker@gsMarkerColor = cmap(14, :)
	end if
	if (x_plot(i).le.(-2.0) .and. x_plot(i).gt.(-2.5)) then
		resMarker@gsMarkerColor = cmap(18, :)
	end if
	if (x_plot(i).le.(-1.5) .and. x_plot(i).gt.(-2.0)) then
		resMarker@gsMarkerColor = cmap(22, :)
	end if
	if (x_plot(i).le.(-1.0) .and. x_plot(i).gt.(-1.5)) then
		resMarker@gsMarkerColor = cmap(26, :)
	end if
	if (x_plot(i).le.(1.0) .and. x_plot(i).gt.(-1.0)) then
		resMarker@gsMarkerColor = cmap(31, :)
	end if
	if (x_plot(i).le.(1.5) .and. x_plot(i).gt.(1.0)) then
		resMarker@gsMarkerColor = cmap(36, :)
	end if
	if (x_plot(i).le.(2.0) .and. x_plot(i).gt.(1.5)) then
		resMarker@gsMarkerColor = cmap(40, :)
	end if
	if (x_plot(i).le.(2.5) .and. x_plot(i).gt.(2.0)) then
		resMarker@gsMarkerColor = cmap(44, :)
	end if
	if (x_plot(i).le.(3.0) .and. x_plot(i).gt.(2.5)) then
		resMarker@gsMarkerColor = cmap(48, :)
	end if
	if (x_plot(i).le.(3.5) .and. x_plot(i).gt.(3.0)) then
		resMarker@gsMarkerColor = cmap(52, :)
	end if
	if (x_plot(i).le.(4.0) .and. x_plot(i).gt.(3.5)) then
		resMarker@gsMarkerColor = cmap(56, :)
	end if
	if (x_plot(i).gt.(4.0)) then
		resMarker@gsMarkerColor = cmap(60, :)
	end if

	if (i.eq.0) then
		delete(resMarker@gsMarkerColor)
		resMarker@gsMarkerColor = "green"
	else if i.eq.(n_time - 1) then
		delete(resMarker@gsMarkerColor)
		resMarker@gsMarkerColor = "black"
	end if
	end if

	marker(i) = gsn_add_polymarker(wks, plot, x_plot(i), y_plot(i), resMarker)

	delete(resMarker@gsMarkerColor)
end do

resP = True
resP@gsnMaximize = True
resP@gsnFrame = False

gsn_panel(wks, plot, (/1, 1/), resP)

frame(wks)

end
