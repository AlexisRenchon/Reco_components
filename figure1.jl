using CairoMakie
using CSV
using DataFrames
using LaTeXStrings
using PlotUtils: optimize_ticks
using Dates

df = CSV.File("inputs/data.csv") |> DataFrame
damm = CSV.File("inputs/DAMM.csv") |> DataFrame

df_DateTime = DateTime.(df.Date, "mm/dd/yyyy H:MM")
dateticks = optimize_ticks(df_DateTime[1], df_DateTime[end])[1]

fontsize_theme = Theme(fontsize = 50)
set_theme!(fontsize_theme)

fig = Figure(size = (3000, 2500), figure_padding = 50)

ax_T = Axis(fig[1, 1], ylabel = L"\text{T} \, (\degree \, \text{C})", ygridvisible = true, spinewidth = 3)
ax_H2O = Axis(fig[2, 1], ylabel = L"\theta \, (\text{m}^{3} \, \text{m}^{-3})", ygridvisible = true, spinewidth = 3)
ax_H2O_rain = Axis(fig[2, 1], ylabel = "Rainfall (mm)", yaxisposition = :right, ygridvisible = false, ylabelcolor = :blue, yticklabelcolor = :blue)
ax_R = Axis(fig[3, 1], ylabel = L"\text{R} \, (\mu\text{mol m}^{-2} \, \text{s}^{-1})", xgridvisible = false, ygridvisible = true, spinewidth = 3)

p_Tair = lines!(ax_T, datetime2unix.(df_DateTime), df.Ta_d, color = "#FFBE0B", linewidth = 4)
p_Tleaf = lines!(ax_T, datetime2unix.(df_DateTime), df.Tcanopy_d, color = "#FB5607", linewidth = 4)
p_Tstem = lines!(ax_T, datetime2unix.(df_DateTime), df.Tstem_d, color = "#FF006E", linewidth = 4)
p_Tsoil = lines!(ax_T, datetime2unix.(df_DateTime), df.Ts_d, color = "#8338EC", linewidth = 4)

p_SWC5 = lines!(ax_H2O, datetime2unix.(df_DateTime), df.SWC_d, color = "#FFBE0B", linewidth = 4)
p_SWC35 = lines!(ax_H2O, datetime2unix.(df_DateTime), df.SWC35_d, color = "#FB5607", linewidth = 4)
p_rain = barplot!(ax_H2O_rain, datetime2unix.(df_DateTime), df.Prep, color = :blue)

p_Rsoil = lines!(ax_R, datetime2unix.(df_DateTime), df.Rsoil_DAMM_d, color = "#FFBE0B", linewidth = 4)
p_Rhetero = lines!(ax_R, datetime2unix.(df_DateTime), df."Rh.model", color = "#FB5607", linewidth = 4)
p_Rroot = lines!(ax_R, datetime2unix.(df_DateTime), df.Rr_d, color = "#FF006E", linewidth = 4)
p_Rstem = lines!(ax_R, datetime2unix.(df_DateTime), df."Rstem.d", color = "#8338EC", linewidth = 4)
p_Reco = lines!(ax_R, datetime2unix.(df_DateTime), df.Re_d_SOLO, color = "#3A86FF", linewidth = 4)

ax_T.xticks[] = (datetime2unix.(dateticks), Dates.format.(dateticks, "m/yy"))
ax_H2O.xticks[] = (datetime2unix.(dateticks), Dates.format.(dateticks, "m/yy"))
ax_R.xticks[] = (datetime2unix.(dateticks), Dates.format.(dateticks, "m/yy"))

hidexdecorations!(ax_T)
hidexdecorations!(ax_H2O)
hidexdecorations!(ax_H2O_rain)

xlims!(ax_T, (datetime2unix(df_DateTime[1]), datetime2unix(df_DateTime[end])))
xlims!(ax_H2O, (datetime2unix(df_DateTime[1]), datetime2unix(df_DateTime[end])))
xlims!(ax_H2O_rain, (datetime2unix(df_DateTime[1]), datetime2unix(df_DateTime[end])))
xlims!(ax_R, (datetime2unix(df_DateTime[1]), datetime2unix(df_DateTime[end])))

ylims!(ax_T, (0, 35))
ylims!(ax_H2O, (0, 0.2))
ylims!(ax_H2O_rain, (0, 80))
ylims!(ax_R, (0, 15))

yspace = maximum(tight_yticklabel_spacing!, [ax_T, ax_H2O, ax_R])
ax_T.yticklabelspace = yspace
ax_H2O.yticklabelspace = yspace
ax_R.yticklabelspace = yspace

rowgap!(fig.layout, 50)

axislegend(ax_T, [p_Tair, p_Tleaf, p_Tstem, p_Tsoil], ["Tair", "Tleaf", "Tstem", "Tsoil"], "", position = :rt, orientation = :horizontal, nbanks = 2)

axislegend(ax_H2O, [p_SWC5, p_SWC35], ["SWC 5cm", "SWC 35cm"], "", position = :rt, orientation = :vertical)

axislegend(ax_R, [p_Rsoil, p_Rhetero, p_Rroot, p_Rstem, p_Reco], ["Rsoil", "Rhetero", "Rroot", "Rstem", "Reco"], "", position = :rt, orientation = :horizontal, nbanks = 2)

fig

save("outputs/figure1.png", fig)

