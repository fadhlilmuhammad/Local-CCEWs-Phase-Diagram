
wave ="WIG"

folderout = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"

dtim = 16
G   = new((/dtim, 31,31/), "float")

G!0 = "tstep"
G!1 = "x"
G!2 = "y"

G&x = fspan(-3.14, 3.14, 31)
G&y = fspan(-4, 4, 31)
; r   = 7.2925*10^-5
;
; beta = 2*r*cos(G&y)/6.378*10^6


if wave.eq."ER" then
  k   = -1
  n = 1
  Hn = 2*G&y
  Hneg1 = center_finite_diff(Hn,Hn,False,0)/(2*n)
  w = -k/(k^2+2*n+1)
else if wave.eq."MRG" then
  k   = -1
  n = 0
  Hn = 1
  Hneg1 = 0
  w = sqrt(k^2/4+1) - k/2
else if wave.eq."KELVIN" then
  n = -1
  k = 1
  w = k
else if wave.eq."EIG" then
  n = 0
  k = 1
  Hn = 1
  Hneg1 = 0
  w = sqrt(k^2+2*n+1)
else if wave.eq."WIG" then
  n = 2
  k = -1
  Hn = 4*(G&y^2) - 2
  Hneg1 = 2*G&y
  w = -sqrt(k^2+2*n+1)
end if
end if
end if
end if
end if

printVarSummary(G)
; print(G)
printVarSummary(G)

; Re  = (44.3/beta)^1/2
L   = 3.14*2

; k   = 1
; print(beta)
T   = 50.
f   = 1./T
; t   = 0
; print("f value: "+T)
print("w value: "+w)
print("k value: "+k)

; print(Hn)
; print(Hn)
; print(Hneg1)

if wave.eq."ER" then

do t = 0, dtim-1
do i = 0, 30
  ; print(G&y(i))
  G(t,:,i)   = (1/(k^2-w^2)) \\
              *((w+k*G&y(i)*Hn(i) - 2*n*w*Hneg1(i))) \\
              *exp((-0.5)*G&y(i)^2)*sin(k* G&x -w*t)

  ; G(:,i) = (1/(k^2-w^2))*((2*G&y(i)^2)*(w+k)-2*w)*exp((-1/2)*G&y(i)^2)*sin(k*G&x-w*t)
end do
end do

else if wave.eq."MRG" .or. wave.eq."EIG" then

do t = 0, dtim-1
do i = 0, 30

G(t,:,i)   = (G&y(i)/(k-w)) \\
            *exp((-0.5)*G&y(i)^2)*sin(k* G&x - w*t)

end do
end do

else if wave.eq."KELVIN" then

do t = 0, dtim-1
do i = 0,30

  G(t,:,i)   = (w/k) \\
              *exp((-0.5)*G&y(i)^2)*cos(k* G&x - w*t)
end do
end do

else if wave.eq."WIG"  then

do t = 0, dtim-1
do i = 0,30

  G(t,:,i)   = (1/(k^2-w^2)) \\
              *((w+k)*G&y(i)*Hn(i) - 2*n*w*Hneg1(i)) \\
              *exp((-0.5)*G&y(i)^2)*sin(k* G&x - w*t)
end do
end do

end if
end if
end if
end if
; print(exp((-0.5)*G&y^2))
printMinMax(G,0)


system("rm "+folderout+"theory/"+wave+"_structure_tstep.nc")
fout = addfile(folderout+"theory/"+wave+"_structure_tstep.nc", "c")
fout->$wave$ = G

do t = 0, dtim-1
; ===========================
; create plot
; ===========================
 wks   = gsn_open_wks ("eps", "/Users/fadhlilrizki/Documents/PhD/thesis/figures/theory/"+"wave_structure_"+t)        ; send graphics to PNG file

 res                 = True                    ; plot mods desired

 res@tiMainString    = wave+" waves"        ; title
 res@cnLevelSpacingF = 2.                      ; contour interval

 res@cnFillOn        = True                    ; turn on color
 res@cnFillPalette   = "NCV_blu_red"           ; choose color map

 res@gsnContourZeroLineThicknessF = 2.	       ; doubles thickness of zero contour
 res@cnLevelSelectionMode = "ManualLevels" ; manual levels
 res@cnMinLevelValF       = -4
 res@cnMaxLevelValF       =  4
 res@cnLevelSpacingF      =  .5

 res@cnLinesOn = False

 plot = gsn_csm_contour(wks, G(tstep|t,y|:,x|:), res)
 delete(wks)
end do
