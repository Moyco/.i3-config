#!/bin/bash
#
# Input parser for i3 bar
# 17 feb 2015 - Electro7

# config
. $(dirname $0)/i3_bar_config

# min init
irc_n_high=0

# parser
while read -r line ; do
  case $line in
    SYS*)
      # conky=, 0 = wday, 1 = mday, 2 = month, 3 = time, 4-5 = up/down eth
      sys_arr=(${line#???})
      # date
      if [ ${res_w} -gt 1024 ]; then
        date="${sys_arr[0]} ${sys_arr[1]} ${sys_arr[2]}"
      else
        date="${sys_arr[1]} ${sys_arr[2]}"
      fi
      date="%{B${date_back} F${date_fore}} ${date} %{B- F-}"
      # time
      time="%{B${hour_back} F${hour_fore}} ${sys_arr[3]} %{B- F-}"
      # eth
      if [ "${sys_arr[4]}" == "down" ]; then
        ethd_v="×"; ethu_v="×";
        eth_cback=${net_down_back}; eth_cfore=${net_down_fore};
      else
        ethd_v=${sys_arr[4]}K; ethu_v=${sys_arr[5]}K;
        if [ ${ethd_v:0:-3} -gt ${net_alert} ] || [ ${ethu_v:0:-3} -gt ${net_alert} ]; then
          eth_cback=${net_up_back}; eth_cfore=${net_up_fore};
        else
          eth_cback=${net_ina_back}; eth_cfore=${net_ina_fore};
        fi
      fi
      ethd="%{F${eth_cfore} B${eth_cback}} %{T2}${icon_dl}%{T1} ${ethd_v}"
      ethu="%{F${eth_cfore}} %{T2}${icon_ul}%{T1} ${ethu_v} %{B- F-}"
      ;;
    VOL*)
      # Volume
      vol="%{T2}${icon_vol}%{T1} ${line#???}"
      ;;
    MPD*)
      # Music
      IFS='|' read -ra musinfo <<< "${line#???}"
      mpd=""
      mpdcolor="${bar_back}"
      mpdicon=""
      case ${musinfo[0]} in
        Playing)
          mpdicon=${icon_play}
          mpdcolor=${music_play}
	  ;;
	Paused)
          mpdicon=${icon_pause}
          mpdcolor=${music_pause}
	  ;;
	Stopped)
          mpdicon=${icon_stop}
          mpdcolor=${music_stop}
	  ;;
	esac
      mpd="${mpd}%{B${mpdcolor} F${music_back}}"
      mpd="${mpd}%{A:${music_prev}:} ${icon_prev} %{A}"
      mpd="${mpd} ${mpdicon} "
      mpd="${mpd}%{B- F-}"
      mpd="${mpd}%{F${mpdcolor}} ${musinfo[1]} - ${musinfo[2]} %{F-}"
      mpd="${mpd}%{B${mpdcolor} F${music_back}}"
      mpd="${mpd}%{A:${music_next}:} ${icon_next} %{A}"
      mpd="${mpd}%{B- F-}"
      ;;
    WSP*)
      # I3 Workspaces
      wsp="%{B${ws_back} F${ws_fore}}%{A4:${ws_mw_up}:}%{A5:${ws_mw_down}:}"
      set -- ${line#???}
      while [ $# -gt 0 ] ; do
        case $1 in
         FOC*|ACT*)
           wsp="${wsp}%{B${ws_foc_back} F${ws_foc_fore}} ${1#???} "
           ;;
         INA*)
           wsp="${wsp}%{B${ws_ina_back} F${ws_ina_fore} A:i3-msg 'workspace ${1#???}':} ${1#???} %{A}"
           ;;
         URG*)
           wsp="${wsp}%{B${ws_urg_back} F${ws_urg_fore} A:i3-msg 'workspace ${1#???}':} ${1#???} %{A}"
           ;;
        esac
        shift
      done
      wsp="${wsp} %{B- F-}%{A}%{A}"
      ;;
    WIN*)
      # window title
      title=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
      title=" ${title}"
      ;;
  esac

  # And finally, output
  printf "%s\n" "%{l}${wsp}${title} %{c}${mpd}%{r}${stab}${ethd}${stab}${ethu}${stab}${vol}${stab}${date}${time}"
  #printf "%s\n" "%{l}${wsp}${title}"
done
