; Author: Dr. Sandro Lubis (Jan 2020)
;         Local equatorial wave phase diagram
;         Lubis, SW, Respati, MR. Impacts of convectively coupled
;         equatorial waves on rainfall extremes in Java, Indonesia.
;         Int J Climatol. 2021; 41: 2418– 2440
; Contact: slubis.geomar@gmail.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "diag_local_wave_phase.ncl"

waves = (/"kelvin", "er", "mjo", "td", "eig", "wig", "mrg", "td-slow"/)


do i = 0, dimsizes(waves)-1
	dir   = "dataout/"
	fname = "waves.northAU.nc"

	opt = True
	opt@id = "134"
	; outname = "local_wave_phase_"+waves(i)+"_forwksum.nc"
	date_start  = 20161224
	date_end    = 20170110
	seas			  = "SHSummer"
	central_lon = 134
	NC				  = True
	PLOT			  = False

	local_phase_diag(dir,fname, waves(i),date_start,date_end,seas,central_lon,NC,PLOT, opt )
end do
