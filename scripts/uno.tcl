#
# Marky's Color Uno v0.98
# Copyright (C) 2004-2011 Mark A. Day (techwhiz@embarqmail.com)
#
# Uno(tm) is Copyright (C) 2001 Mattel, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# default settings (these are overridden by uno.cfg)
set UnoAds		0
set UnoDebug 		0
set UnoChan 		"#uno"
set UnoRobot 		$botnick
set UnoPointsName 	"Points"
set UnoStopAfter 	3
set UnoJoinAnyTime	1
set UnoUseDCC		0
set UnoBonus		700
set UnoWildDrawTwos	0
set UnoWDFAnyTime	1
set UnoMaxNickLen	9
set UnoMaxPlayers	10
set UnoOpFlags		"-"
set UnoNTC		"NOTICE"
set UnoCFGFile		"scripts/uno.cfg"
set UnoScoreFile 	"UnoScores"
set UnoVersion 		"0.98.9"

# command binds
bind pub - !uno UnoInit
bind pub - !stop UnoStop
bind pub - !pause UnoPause
bind pub - !join UnoJoinBotPlayer
bind pub - !remove UnoRemove
bind pub - !unocmds UnoCmds
bind pub - !unowon UnoWon
bind pub - !unotop10 UnoTopTen
bind pub - !unotop3last UnoTopThreeLast
bind pub - !unostats UnoPlayStats
bind pub - !unorecords UnoRecords
bind pub - !unorow UnoCurrentRow
bind pub - !unoversion UnoVersion

# dcc commands
bind dcc - unohands dccunohands
bind dcc - unowritecfg dcc_unowriteconfig
bind dcc - unorehash dcc_unorehash
bind dcc - unopoints dcc_unopoints

# monthly score reset
bind time - "00 00 01 * *" UnoNewMonth

# rehash
bind evnt - "prerehash" unoevnt:prerehash
proc unoevnt:prerehash {type} {
 global UnoRobot UnoChan
 UnoStop $UnoRobot "console" $UnoRobot $UnoChan ""
}
# restart
bind evnt - "prerestart" unoevnt:prerestart
proc unoevnt:prerestart {type} {
 global UnoRobot UnoChan
 UnoStop $UnoRobot "console" $UnoRobot $UnoChan ""
}

# global variables
set UnoOn 0
set UnoMode 0
set UnoPaused 0
set UnoPlayers 0
set MasterDeck ""
set UnoDeck ""
set DiscardPile ""
set PlayCard ""
set RoundRobin ""
set ThisPlayer ""
set ThisPlayerIDX 0
set UnoStartTime [unixtime]
set IsColorChange 0
set ColorPicker ""
set IsDraw 0
set UnoIDX ""
set UnPlayedRounds 0
set UnoWinDefault 0
set UnoLastWinner ""
set UnoLastIdler ""
set UnoWinsInARow 0

# card types
set unocardtype_invalid 0
set unocardtype_skip 1
set unocardtype_reverse 2
set unocardtype_draw2 3
set unocardtype_draw4 4
set unocardtype_wild 5
set unocardtype_number 6

# scores, records and ads
set UnoLastMonthCards(0) "Nobody 0"
set UnoLastMonthCards(1) "Nobody 0"
set UnoLastMonthCards(2) "Nobody 0"
set UnoLastMonthGames(0) "Nobody 0"
set UnoLastMonthGames(1) "Nobody 0"
set UnoLastMonthGames(2) "Nobody 0"
set UnoFast "Nobody 600"
set UnoHigh "Nobody 0"
set UnoPlayed "Nobody 0"
set UnoRow "Nobody 0"
set UnoRecordHigh "Nobody 0"
set UnoRecordFast "Nobody 600"
set UnoRecordCard "Nobody 0"
set UnoRecordWins "Nobody 0"
set UnoRecordPlayed "Nobody 0"
set UnoRecordRow "Nobody 0"
set UnoAdNumber 0

# card stats
set CardStats(played) 0

# timers
set UnoStartTimer ""
set UnoSkipTimer ""
set UnoCycleTimer ""
set UnoBotTimer ""

#
# grace periods and timeouts ( AutoSkipPeriod can be raised but dont go below 2)
#

# time to skip an inactive player
set AutoSkipPeriod 2

# time to join game
set StartGracePeriod 30

# time between games
set UnoCycleTime 30

# internal bot player use dont change
set RobotRestartPeriod 1

# nick colors
set UnoNickColors "6 13 3 7 12 10 4 11 9 8 5"

# cards and logo
set UnoRedCard		"\0030,04 Red "
set UnoGreenCard	"\0030,03 Green "
set UnoBlueCard		"\0030,12 Blue "
set UnoYellowCard	"\0031,08 Yellow "
set UnoSkipCard		"\002Skip\002 \003 "
set UnoReverseCard	"\002Reverse\002 \003 "
set UnoDrawTwoCard	"\002Draw Two\002 \003 "
set UnoWildCard		"\0031,8 \002W\0030,3I \0030,4L\0030,12D\002 \003 "
set UnoWildDrawFourCard "\0031,8 \002W\0030,3I \0030,4L\0030,12D \0031,8D\0030,3r\0030,4a\0030,12w \0031,8F\0030,3o\0030,4u\0030,12r\002 \003 "
set UnoLogo		"\002\0033U\00312N\00313O\00308!\002\003"

#
# bind channel commands 
#
proc UnoBindCmds {} {
 bind pub - jo UnoJoin
 bind pub - od UnoOrder
 bind pub - ti UnoTime
 bind pub - ca UnoShowCards
 bind pub - pl UnoPlayCard
 bind pub - cd UnoTopCard
 bind pub - tu UnoTurn
 bind pub - dr UnoDraw
 bind pub - co UnoColorChange
 bind pub - pa UnoPass
 bind pub - ct UnoCardCount
 bind pub - st UnoCardStats

 bind chon - * unologin:dcc
 bind chof - * unologout:dcc
 bind filt - .quit* unologout:filt
}

#
# unbind channel commands 
#
proc UnoUnbindCmds {} {
 catch {unbind pub - jo UnoJoin}
 catch {unbind pub - od UnoOrder}
 catch {unbind pub - ti UnoTime}
 catch {unbind pub - ca UnoShowCards}
 catch {unbind pub - pl UnoPlayCard}
 catch {unbind pub - cd UnoTopCard}
 catch {unbind pub - tu UnoTurn}
 catch {unbind pub - dr UnoDraw}
 catch {unbind pub - co UnoColorChange}
 catch {unbind pub - pa UnoPass}
 catch {unbind pub - ct UnoCardCount}
 catch {unbind pub - st UnoCardStats}

 catch {unbind chon - * unologin:dcc}
 catch {unbind chof - * unologout:dcc}
 catch {unbind filt - .quit* unologout:filt}
}

#
# reset game variables
#
proc UnoReset {} {
 global UnoOn UnoMode UnoPaused UnoPlayers RoundRobin UnoDeck ThisPlayer ThisPlayerIDX PlayCard
 global DiscardPile IsColorChange ColorPicker IsDraw UnoIDX MasterDeck CardStats
 global UnoStartTimer UnoSkipTimer UnoCycleTimer UnoWinDefault UnoRobot botnick UnoLastIdler

 set UnoMode 0
 set UnoPaused 0
 set UnoPlayers 0
 set MasterDeck ""
 set UnoDeck ""
 set DiscardPile ""
 set RoundRobin ""
 set ThisPlayer ""
 set ThisPlayerIDX 0
 set PlayCard ""
 set IsColorChange 0
 set ColorPicker ""
 set IsDraw 0
 set UnoIDX ""
 set UnoAdNumber 0
 set UnoWinDefault 0
 set UnoLastIdler ""

 set CardStats(played) 0

 set UnoStartTimer ""
 set UnoSkipTimer ""
 set UnoCycleTimer ""

 set UnoRobot $botnick

 return
}

# return 1 if is this the uno channel, else return 0
proc uno_ischan {chan} {
 global UnoChan
 if {([string tolower $chan] == [string tolower $UnoChan])} {return 1}
 return 0
}
# return 1 if is this the uno channel and uno is running, else return 0
proc uno_isrunning {chan} {
 global UnoMode
 if {([uno_ischan $chan])&&($UnoMode == 2)} {return 1}
 return 0
}

# remove player dcc list
proc uno_removedccplayers { } {
 global RoundRobin UnoDCCIDX
 set pcount 0
 while {[lindex $RoundRobin $pcount] != ""} {
  set pnick [lindex $RoundRobin $pcount]
  if [info exist UnoDCCIDX($pnick)] {unset UnoDCCIDX($pnick)}
  incr pcount
 }
}

#
# stop a game
#
proc UnoStop {nick uhost hand chan txt} {
 global UnoOn UnoPaused UnPlayedRounds UnoStartTimer UnoSkipTimer UnoCycleTimer UnoLastWinner UnoWinsInARow

 if {(![uno_ischan $chan])||($UnoOn == 0)} {return}

 catch {killutimer $UnoStartTimer}
 catch {killtimer $UnoSkipTimer}
 catch {killutimer $UnoCycleTimer}

 # remove player dcc list
 uno_removedccplayers

 set UnoOn 0
 set UnoPaused 0
 set UnPlayedRounds 0
 set UnoLastWinner ""
 set UnoWinsInARow 0

 UnoUnbindCmds

 UnoReset

 unochanmsg "stopped by $nick"

 return
}

#
# first entry
#
proc UnoInit {nick uhost hand chan txt} {
 global UnoOn
 if {(![uno_ischan $chan])||($UnoOn > 0)} {return}
 #unochanmsg "$nick\!$uhost"
 set UnoOn 1
 UnoBindCmds
 UnoNext
 return
}

#
# initialize a new game
#
proc UnoNext {} {
 global UnoOn MasterDeck UnoDeck UnoMode StartGracePeriod UnoHand UnoNickColor UnoVersion UnoStartTimer UnoSkipTimer

 if {!$UnoOn} {return}

 UnoReset

 set UnoMode 1

 set MasterDeck [list B0 B1 B1 B2 B2 B3 B3 B4 B4 B5 B5 B6 B6 B7 B7 B8 B8 B9 B9 BR BR BS BS BD BD R0 R1 R1 R2 R2 R3 R3 R4 R4 R5 R5 R6 R6 R7 R7 R8 R8 R9 R9 RR RR RS RS RD RD Y0 Y1 Y1 Y2 Y2 Y3 Y3 Y4 Y4 Y5 Y5 Y6 Y6 Y7 Y7 Y8 Y8 Y9 Y9 YR YR YS YS YD YD G0 G1 G1 G2 G2 G3 G3 G4 G4 G5 G5 G6 G6 G7 G7 G8 G8 G9 G9 GR GR GS GS GD GD W W W W WD WD WD WD]

 unochanmsg "$UnoVersion by Marky"

 set done 0
 while {!$done} {
  set rseed [rand 65535]
  if {$rseed} {set done 1}
 }
 set newrand [expr srand($rseed)]
 set newrand [rand [llength $MasterDeck]]

 set UnoDeck ""
 while {[llength $UnoDeck] != 108} {
  set pnum [rand [llength $MasterDeck]]
  set pcard [lindex $MasterDeck $pnum]
  lappend UnoDeck $pcard
  set MasterDeck [lreplace $MasterDeck $pnum $pnum]
 }

 if [info exist UnoHand] {unset UnoHand}
 if [info exist UnoNickColor] {unset UnoNickColor}

 unochanmsg "You have \00314\002[UnoDuration $StartGracePeriod]\002\003 to join uno"

 set UnoStartTimer [utimer $StartGracePeriod UnoStart]

 return
}

#
# cycle a new game
#
proc UnoCycle {} {
 global UnoOn UnoMode UnoCycleTime UnoCycleTimer UnoSkipTimer UnoAds

 if {!$UnoOn} {return}

 set UnoMode 4
 catch {killtimer $UnoSkipTimer}

 if {$UnoAds} {
  set AdTime [expr $UnoCycleTime /2]
  set UnoAdTimer [utimer $AdTime UnoScoreAdvertise]
 }

 set UnoCycleTimer [utimer $UnoCycleTime UnoNext]

 return
}

# force bot player to join
proc UnoJoinBotPlayer {nick uhost hand chan txt} {
 global UnoMode UnoOn
 if {!$UnoOn || ($UnoMode != 2)} {return}
 UnoBotPlayerJoins
 return 0
}

# bot player joins in if no one else does
proc UnoBotPlayerJoins {} {
 global UnoPlayers RoundRobin UnoIDX UnoRobot UnoLogo UnoDebug UnoHand UnoNickColor

 # prevent bot player from joining multiple times
 if [info exist UnoHand($UnoRobot)] { return }

 incr UnoPlayers

 lappend RoundRobin $UnoRobot
 lappend UnoIDX $UnoRobot

 set UnoHand($UnoRobot) ""
 set UnoNickColor($UnoRobot) [unocolornick $UnoPlayers]

 unomsg "[unonik $UnoRobot]\003 joins $UnoLogo"

 # deal hand to bot
 uno_newplayerhand $UnoRobot
}

#
# start a new game
#
proc UnoStart {} {
 global UnoChan UnoOn UnoCycleTime UnoRobot UnoDebug UnoIDX UnoStartTime UnoPlayers RoundRobin ThisPlayer ThisPlayerIDX UnoDeck DiscardPile UnoMode UnoHand AutoSkipPeriod
 global UnoSkipTimer UnPlayedRounds UnoStopAfter UnoNickColor UnoLogo

 if {!$UnoOn} {return}

 if {![llength $RoundRobin]} {
  unochanmsg "no players, next game in \00314[UnoDuration $UnoCycleTime]"
  incr UnPlayedRounds
  if {($UnoStopAfter > 0)&&($UnPlayedRounds >= $UnoStopAfter)} {
    unochanmsg "idle $UnoStopAfter rounds"
    utimer 1 "UnoStop $UnoRobot $UnoRobot none $UnoChan none"
    return
  }

  UnoCycle

  return
 }

 # bot joins if one player
 if {[llength $RoundRobin] == 1} {
  UnoBotPlayerJoins
 }

 unomsg "Welcome to $UnoLogo"
 unomsg "\00314$UnoPlayers\003 players this round:\00314 $RoundRobin"

 set UnoMode 2

 set ThisPlayer [lindex $RoundRobin 0]

 # draw first card from deck
 set DiscardPile ""
 set pcardnum [rand [llength $UnoDeck]]
 set pcard [lindex $UnoDeck $pcardnum]

 # play doesnt start with a wild card
 while {[string range $pcard 0 0] == "W"} {
  set pcardnum [rand [llength $UnoDeck]]
  set pcard [lindex $UnoDeck $pcardnum]
 }

 # put first card on top of discard pile
 uno_addtodiscardpile $pcard
 set Card [uno_cardcolor $pcard]

 set UnoDeck [lreplace $UnoDeck $pcardnum $pcardnum]

 # first player draws two if first card is a draw two, but not skipped
 unomsg "[unonik $ThisPlayer]\003 plays first... The top card is $Card"

 if {([string range $pcard 0 0] != "W")&&([string range $pcard 1 1] == "D")} {
   uno_adddrawtohand $ThisPlayer $ThisPlayerIDX 2
   unomsg "[unonik $ThisPlayer]\003 \002drew two\002 cards"
 }

 uno_showcards $ThisPlayer $ThisPlayerIDX

 # start autoskip timer
 set UnoSkipTimer [timer $AutoSkipPeriod UnoAutoSkip]

 set UnPlayedRounds 0

 # running game time
 set UnoStartTime [unixtime]
}

#
# deal full hand of 7 cards
#
proc uno_newplayerhand {cplayer} {
 global UnoDeck UnoHand
 # shuffle deck if needed
 UnoShuffle 7
 # deal cards to player
 set picknum 0
 while {[llength $UnoHand($cplayer)] != 7} {
  set pick [lindex $UnoDeck $picknum]
  lappend UnoHand($cplayer) $pick
  set UnoDeck [lreplace $UnoDeck $picknum $picknum]
 }
}

#
# add a player
#
proc UnoJoin {nick uhost hand chan txt} {
 global UnoDebug UnoIDX UnoMode UnoPlayers RoundRobin UnoHand UnoNickColor UnoMaxPlayers UnoDCCIDX UnoLogo UnoJoinAnyTime
 global UnoUseDCC

 if {(![uno_ischan $chan])||($UnoMode < 1)||($UnoMode > 2)} {return}

 if {!$UnoJoinAnyTime && ($UnoMode == 2)} {return}

 # player is already joined
 set pcount 0
 while {[lindex $RoundRobin $pcount] != ""} {
  if {[lindex $RoundRobin $pcount] == $nick} {
   return
  }
  incr pcount
 }

 if {[llength $RoundRobin] >= $UnoMaxPlayers} {
  unogntc $nick "$UnoLogo maximum of $UnoMaxPlayers players reached... try next round, $nick"
  return
 }

 incr UnoPlayers

 lappend RoundRobin $nick
 lappend UnoIDX $nick

 if [info exist UnoHand($nick)] {unset UnoHand($nick)}
 if [info exist UnoNickColor($nick)] {unset UnoNickColor($nick)}
 if [info exist UnoDCCIDX($nick)] {unset UnoDCCIDX($nick)}

 set UnoHand($nick) ""
 set UnoNickColor($nick) [unocolornick $UnoPlayers]

 # if player is in dcc chat, use that socket for card output (fast)
 set UnoDCCIDX($nick) -1

 if {$UnoUseDCC} {
  set dhand [nick2hand $nick $chan] 
  if {($dhand != "")&&($dhand != "*")} {
   set idx [hand2idx $dhand]
   if {$idx != -1} {
    set UnoDCCIDX($nick) $idx
   } {
    set UnoDCCIDX($nick) -1
   }
  }
 }

 # deal hand
 uno_newplayerhand $nick

 #if {$UnoDebug > 1} { unolog $nick $UnoHand($nick) }

 unomsg "[unonik $nick]\003 joins $UnoLogo"

 unontc $nick "[uno_cardcolorall $nick]"
}

#
# card handling
#

# remove played card from hand
proc uno_removecardfromhand {cplayer ccard} {
 global UnoHand
 set UnoHand($cplayer) [lreplace $UnoHand($cplayer) $ccard $ccard]
}

# add card to discard pile
proc uno_addtodiscardpile {ccard} {
 global DiscardPile PlayCard
 set PlayCard $ccard
 if {[string range $ccard 0 0] != ""} { lappend DiscardPile $ccard }
}

# add num drawn cards to hand
proc uno_adddrawtohand {cplayer idx num} {
 global UnoHand UnoDeck RoundRobin

 # check if deck needs reshuffling
 UnoShuffle $num

 set newhand [expr [llength $UnoHand($cplayer)] + $num]

 set Drawn ""
 set pcardnum 0
 while {[llength $UnoHand($cplayer)] != $newhand} {
  set pcard [lindex $UnoDeck $pcardnum]
  set UnoDeck [lreplace $UnoDeck $pcardnum $pcardnum]
  lappend UnoHand($cplayer) $pcard
  append Drawn [uno_cardcolor $pcard]
 }
 uno_showdraw $idx $Drawn
}

# reset isdraw flag
proc uno_isdrawreset {} {
 global IsDraw
 set IsDraw 0
}

#
# player with no cards left wins
#

proc uno_checkwin {cplayer crd} {
 global UnoHand
 if {[llength $UnoHand($cplayer)]} {return 0}
 uno_showwin $cplayer $crd
 UnoWin $cplayer
 UnoCycle
 return 1
}

# win on a draw card
proc uno_checkwindraw {cplayer crd dplayer dplayeridx num} {
 global UnoHand
 if {[llength $UnoHand($cplayer)]} {return 0}
 uno_adddrawtohand $dplayer $dplayeridx $num
 uno_showwin $cplayer $crd
 UnoWin $cplayer
 UnoCycle
 return 1
}

#
# check for wdf card in hand
#
proc uno_checkhandwdf {cplayer} {
 global UnoHand
 set ccount 0
 while {$ccount < [llength $UnoHand($cplayer)]} {
  set pcard [lindex $UnoHand($cplayer) $ccount]
  set hc0 [string range $pcard 0 0]
  set hc1 [string range $pcard 1 1]
  if {($hc0 == "W") && ($hc1 == "D")} { return 1 }
  incr ccount
 }
 return 0
}

#
# check if player has same color card in hand for wdf
#
proc uno_checkhandcolor {cplayer} {
 global PlayCard UnoHand

 # color of card in play
 set cip0 [string range $PlayCard 0 0]

 set ccount 0
 while {$ccount < [llength $UnoHand($cplayer)]} {
  set pcard [lindex $UnoHand($cplayer) $ccount]
  set hc0 [string range $pcard 0 0]
  if {([uno_iscolorcard $cip0]) && ($cip0 == $hc0)} {return 1}
  incr ccount
 }
 return 0
}

#
# draw a card
#
proc UnoDraw {nick uhost hand chan txt} {
 global UnoMode IsDraw ThisPlayer ThisPlayerIDX

 if {(![uno_ischan $chan])||($UnoMode != 2)||($nick != $ThisPlayer)} {return}

 uno_autoskipreset $nick

 if {$IsDraw} {
  unontc $nick "You've already drawn a card, $nick, play a card or pass"
  return
 }

 if {[uno_checkhandwdf $ThisPlayer]} {
  unontc $nick "You have a playable card in your hand already, $nick, you must play it"
  return
 }

 set IsDraw 1

 uno_adddrawtohand $ThisPlayer $ThisPlayerIDX 1

 uno_showwhodrew $nick

 return
}

#
# pass a turn
#
proc UnoPass {nick uhost hand chan txt} {
 global UnoMode IsDraw ThisPlayer ThisPlayerIDX IsColorChange

 if {(![uno_ischan $chan])||($UnoMode != 2)||($nick != $ThisPlayer)||($IsColorChange == 1)} {return}

 uno_autoskipreset $nick

 if {$IsDraw} {
  uno_isdrawreset

  uno_nextplayer

  uno_showplaypass $nick $ThisPlayer

  uno_showcards $ThisPlayer $ThisPlayerIDX

  uno_restartbotplayer
 } {
  unontc $nick "You must draw a card before you can pass, $nick"
 }

 return
}

#
# color change
#
proc UnoColorChange {nick uhost hand chan txt} {
 global UnoMode PlayCard ColorPicker IsColorChange ThisPlayer ThisPlayerIDX
 global UnoRedCard UnoGreenCard UnoBlueCard UnoYellowCard

 #if {(![uno_ischan $chan])||($UnoMode != 2)||($nick != $ColorPicker)||(!$IsColorChange)} {return}
 if {($UnoMode != 2)||($nick != $ColorPicker)||(!$IsColorChange)} {return}

 uno_autoskipreset $nick

 regsub -all \[`.,!{}\ ] $txt "" txt

 set NewColor [string toupper [string range $txt 0 0]]

 switch $NewColor {
  "R" { set PlayCard "R"; set Card "$UnoRedCard\003"}
  "G" { set PlayCard "G"; set Card "$UnoGreenCard\003"}
  "B" { set PlayCard "B"; set Card "$UnoBlueCard\003"}
  "Y" { set PlayCard "Y"; set Card "$UnoYellowCard\003"}
  default { unontc $nick "choose a valid color \(r,g,b or y\)"; return }
 }

 uno_nextplayer

 unomsg "[unonik $ColorPicker]\003 chose $Card, play continues with [unonik $ThisPlayer]"

 uno_showcards $ThisPlayer $ThisPlayerIDX

 uno_isdrawreset

 set IsColorChange 0
 set ColorPicker ""

 uno_restartbotplayer

 return
}

#
# skip card
#
proc uno_playskipcard {nick pickednum crd} {
 global ThisPlayer ThisPlayerIDX RoundRobin

 uno_removecardfromhand $nick $pickednum

 uno_addtodiscardpile $crd

 set SkipPlayer $ThisPlayer

 uno_nextplayer

 set SkippedPlayer [lindex $RoundRobin $ThisPlayerIDX]

 uno_nextplayer

 if {[uno_checkwin $SkipPlayer [uno_cardcolor $crd]]} { return }

 uno_showplayskip $nick [uno_cardcolor $crd] $SkippedPlayer $ThisPlayer

 uno_checkuno $SkipPlayer

 uno_showcards $ThisPlayer $ThisPlayerIDX

 uno_isdrawreset
}

#
# reverse card
#
proc uno_playreversecard {nick pickednum crd} {
 global UnoIDX ThisPlayer ThisPlayerIDX RoundRobin

 uno_removecardfromhand $nick $pickednum

 uno_addtodiscardpile $crd

 # reverse roundrobin and move to next player
 set NewRoundRobin ""
 set OrigOrderLength [llength $RoundRobin]
 set IDX $OrigOrderLength

 while {$OrigOrderLength != [llength $NewRoundRobin]} {
  set IDX [expr ($IDX - 1)]
  lappend NewRoundRobin [lindex $RoundRobin $IDX]
 }

 set Newindexorder ""
 set OrigindexLength [llength $UnoIDX]
 set IDX $OrigindexLength

 while {$OrigindexLength != [llength $Newindexorder]} {
  set IDX [expr ($IDX - 1)]
  lappend Newindexorder [lindex $UnoIDX $IDX]
 }

 set UnoIDX $Newindexorder
 set RoundRobin $NewRoundRobin

 set ReversePlayer $ThisPlayer

 # next player after reversing roundrobin
 set pcount 0
 while {$pcount != [llength $RoundRobin]} {
  if {[lindex $RoundRobin $pcount] == $ThisPlayer} {
   set ThisPlayerIDX $pcount
   break
  }
  incr pcount
 }

 # less than 3 players acts like a skip card
 if {[llength $RoundRobin] > 2} {
  incr ThisPlayerIDX
  if {$ThisPlayerIDX >= [llength $RoundRobin]} {set ThisPlayerIDX 0}
 }

 set ThisPlayer [lindex $RoundRobin $ThisPlayerIDX]

 if {[uno_checkwin $ReversePlayer [uno_cardcolor $crd]]} { return }

 uno_showplaycard $nick [uno_cardcolor $crd] $ThisPlayer

 uno_checkuno $ReversePlayer

 uno_showcards $ThisPlayer $ThisPlayerIDX

 uno_isdrawreset
}

#
# draw two card
#
proc uno_playdrawtwocard {nick pickednum crd} {
 global ThisPlayer ThisPlayerIDX RoundRobin

 uno_removecardfromhand $nick $pickednum

 uno_addtodiscardpile $crd

 set DrawPlayer $ThisPlayer
 set DrawPlayerIDX $ThisPlayerIDX

 # move to the player that draws
 uno_nextplayer

 set PlayerThatDrew $ThisPlayer
 set PlayerThatDrewIDX $ThisPlayerIDX

 # move to the player skipped to
 uno_nextplayer

 if {[uno_checkwindraw $nick [uno_cardcolor $crd] $PlayerThatDrew $PlayerThatDrewIDX 2]} { return }

 uno_showplaydraw $nick [uno_cardcolor $crd] $PlayerThatDrew $ThisPlayer

 uno_adddrawtohand $PlayerThatDrew $PlayerThatDrewIDX 2

 uno_checkuno $nick

 uno_showcards $ThisPlayer $ThisPlayerIDX

 uno_isdrawreset
}

#
# wild draw four card
#
proc uno_playwilddrawfourcard {nick pickednum crd isrobot} {
 global ThisPlayer ThisPlayerIDX RoundRobin IsColorChange ColorPicker

 set ColorPicker $ThisPlayer

 uno_removecardfromhand $nick $pickednum

 uno_addtodiscardpile $crd

 # move to the player that draws
 uno_nextplayer

 set PlayerThatDrew $ThisPlayer
 set PlayerThatDrewIDX $ThisPlayerIDX

 # bot chooses a color
 if {$isrobot > 0} {
  set cip [uno_botpickcolor]
  uno_nextplayer
 }

 if {[uno_checkwindraw $nick [uno_cardcolor $crd] $PlayerThatDrew $PlayerThatDrewIDX 4]} { return }

 if {$isrobot} {
  uno_showbotplaywildfour $ColorPicker $PlayerThatDrew $ColorPicker $cip $ThisPlayer
  set ColorPicker ""
  set IsColorChange 0
  uno_showcards $ThisPlayer $ThisPlayerIDX
 } {
  uno_showplaywildfour $nick $PlayerThatDrew $ColorPicker
  set IsColorChange 1
 }

 uno_adddrawtohand $PlayerThatDrew $PlayerThatDrewIDX 4

 uno_checkuno $nick

 uno_isdrawreset
}

#
# wild card
#
proc uno_playwildcard {nick pickednum crd isrobot} {
 global ThisPlayer ThisPlayerIDX RoundRobin IsColorChange ColorPicker

 set ColorPicker $ThisPlayer

 uno_removecardfromhand $nick $pickednum

 uno_addtodiscardpile $crd

 if {$isrobot} {
  # make a color choice
  set cip [uno_botpickcolor]
  uno_nextplayer
 }

 # no cards remaining = winner
 if {[uno_checkwin $nick [uno_cardcolor $crd]]} { return }

 if {$isrobot} {
  uno_showbotplaywild $nick $ColorPicker $cip $ThisPlayer
  set ColorPicker ""
  uno_showcards $ThisPlayer $ThisPlayerIDX
  set IsColorChange 0
 } {
  uno_showplaywild $nick $ColorPicker
  set IsColorChange 1
 }

 uno_checkuno $nick

 uno_isdrawreset
}

#
# number card
#
proc uno_playnumbercard {nick pickednum crd} {
 global ThisPlayer ThisPlayerIDX RoundRobin

 uno_removecardfromhand $nick $pickednum

 uno_addtodiscardpile $crd

 set NumberCardPlayer $ThisPlayer

 uno_nextplayer

 if {[uno_checkwin $NumberCardPlayer [uno_cardcolor $crd]]} { return }

 uno_showplaycard $nick [uno_cardcolor $crd] $ThisPlayer

 uno_checkuno $NumberCardPlayer

 uno_showcards $ThisPlayer $ThisPlayerIDX

 uno_isdrawreset
}

#
# attempt to find card in hand
#
proc uno_findcard {nick pickednum crd} {
 global UnoRobot ThisPlayer ThisPlayerIDX PlayCard UnoWildDrawTwos UnoWDFAnyTime

  #if {$UnoDebug > 1} {unolog $UnoRobot "uno_findcard: [lindex $UnoHand($ThisPlayer) $pickednum"}

  # card in hand
  set c0 [string range $crd 0 0]
  set c1 [string range $crd 1 1]

  # card in play
  set cip0 [string range $PlayCard 0 0]
  set cip1 [string range $PlayCard 1 1]

  # skip
  if {$c1 == "S"} {
   if {($c0 == $cip0)||($c1 == $cip1)} { return 1 }
   return 0
  }

  # reverse
  if {$c1 == "R"} {
   if {($c0 == $cip0)||($c1 == $cip1)} { return 2 }
   return 0
  }

  # wild draw four
  if {($c0 == "W")&&($c1 == "D")} {
   if {$UnoWDFAnyTime} { return 4 }
   if {![uno_checkhandcolor $ThisPlayer]} { return 4 }
   return 7
  }

  # wild
  if {$c0 == "W"} { return 5 }

  # draw two
  if {$c1 == "D"} {
   set CardOk 0
   if {$c0 == $cip0} {set CardOk 1}
   if {$UnoWildDrawTwos != 0} { 
    if {($cip0 != "W")&&($cip1 == "D")} {set CardOk 1}
    if {$cip1 != ""} {set CardOk 1}
   } {
    if {($cip0 != "W")&&($cip1 == "D")} {set CardOk 1}
   }
   if {$CardOk} {
    return 3
   }
   return 0
  }

  # number card
  if {($c1 == -1)} {return 0}
  if {($c0 == $cip0)||(($cip1 != "")&&($c1 == $cip1))} { return 6 }

  return 0
}

#
# play the picked card
#
# cardfound is set by uno_findcard, which returns a card type as follows:
#
# 0 invalid card
# 1 skip card
# 2 reverse card
# 3 draw-two card
# 4 draw-four card
# 5 wild card
# 6 number card
# 7 illegal card
#
proc uno_playactualcard {nick cardfound pickednum crd isrobot} {
 global CardStats
 switch $cardfound {
  0 {
   if {$isrobot} {
    unolog $nick "UnoRobot: oops $crd"
   } {
    unontc $nick "Oops! Not a valid card... draw or play another"
   }
  }
  1 { 
   uno_playskipcard $nick $pickednum $crd
   incr CardStats(played)
   uno_restartbotplayer
  }
  2 { 
   uno_playreversecard $nick $pickednum $crd
   incr CardStats(played)
   uno_restartbotplayer
  }
  3 { 
   uno_playdrawtwocard $nick $pickednum $crd
   incr CardStats(played)
   uno_restartbotplayer
  }
  4 {
   uno_playwilddrawfourcard $nick $pickednum $crd $isrobot
   incr CardStats(played)
   if {$isrobot} { uno_restartbotplayer }
  }
  5 {
   uno_playwildcard $nick $pickednum $crd $isrobot
   incr CardStats(played)
  }
  6 {
   uno_playnumbercard $nick $pickednum $crd
   incr CardStats(played)
   if {!$isrobot} { uno_restartbotplayer }
  }
  7 {
   if {$isrobot} {
    unolog $nick "UnoRobot: oops valid card in-hand"; return
    uno_restartbotplayer
   } {
    unontc $nick "You have a valid color card in-hand, $nick, you must play it first"; return
   }
  }
 }
}

#
# attempt to play a card
#
proc UnoPlayCard {nick uhost hand chan txt} {
 global UnoMode IsColorChange UnoHand ThisPlayer

 if {(![uno_ischan $chan])||($UnoMode != 2)||($nick != $ThisPlayer)||($IsColorChange == 1)} {return}

 uno_autoskipreset $nick

 regsub -all \[`,.!{}\ ] $txt "" txt

 if {$txt == ""} {return}

 set pcard [string toupper [string range $txt 0 1]]

 set CardInHand 0

 set pcount 0
 while {[lindex $UnoHand($nick) $pcount] != ""} {
  if {$pcard == [lindex $UnoHand($nick) $pcount]} {
   set pcardnum $pcount
   uno_playactualcard $nick [uno_findcard $nick $pcardnum $pcard] $pcardnum $pcard 0
   return
  }
  incr pcount
 }
 unontc $nick "You don't have that card $nick, draw or play another"
 return
}

#
# robot player
#

# robot tries to find card from hand
proc uno_botplayertrycard {} {
 global PlayCard UnoHand ThisPlayer

 # card in play
 set cip0 [string range $PlayCard 0 0]
 set cip1 [string range $PlayCard 1 1]

 set colorcardinplay [uno_iscolorcard $cip0]

 set Tier 0
 set TierMax 8

 # Tier is the order in which the bot player chooses cards:
 #  0 draw two
 #  1 skip
 #  2 reverse
 #  skip or reverse on same color
 #  color or number match
 #  draw four
 #  wild

 while {$Tier < $TierMax} {
  set CardCount 0
  while {$CardCount < [llength $UnoHand($ThisPlayer)]} {

   set pcard [lindex $UnoHand($ThisPlayer) $CardCount]

   # card in hand
   set hc0 [string range $pcard 0 0]
   set hc1 [string range $pcard 1 1]

   set colorcardinhand [uno_iscolorcard $hc0]

   switch $Tier {
    0 {if {($colorcardinplay)&&($hc0 == $cip0)&&($hc1 == "D")} {return $CardCount}}
    1 {if {($colorcardinplay)&&($cip1 == "D")&&($colorcardinhand)&&($hc1 == "D")} {return $CardCount}}
    2 {if {($cip1 == "S")&&($hc1 == "S")} {return $CardCount}}
    3 {if {($cip1 == "R")&&($hc1 == "R")} {return $CardCount}}
    4 {if {($hc0 == $cip0)&&(($hc1 == "S")||($hc1 == "R"))} {return $CardCount}}
    5 {if {($hc0 == $cip0)||(($hc1 != "D")&&($hc1 == $cip1))} {return $CardCount}}
    6 {if {($hc0 == "W")&&($hc1 == "D")} {return $CardCount}}
    7 {if {($hc0 == "W")} {return $CardCount}}
   }
   incr CardCount
  }
  incr Tier
 }
 return -1;
}

proc UnoRobotPlayer {} {
 global UnoDeck UnoHand ThisPlayer ThisPlayerIDX UnoRobot

 set CardOk -1

 uno_isdrawreset

 set UnoHand($ThisPlayer) [uno_sorthand $UnoHand($ThisPlayer)]

 # look for card in hand
 set CardOk [uno_botplayertrycard]

 # play card if found
 if {$CardOk > -1} {
  set pcard [lindex $UnoHand($ThisPlayer) $CardOk]
  uno_playactualcard $UnoRobot [uno_findcard $UnoRobot $CardOk $pcard] $CardOk $pcard 1
  return
 }

 # bot draws a card
 UnoShuffle 1

 set dcardnum 0
 set dcard [lindex $UnoDeck $dcardnum]
 lappend UnoHand($ThisPlayer) $dcard
 set UnoDeck [lreplace $UnoDeck $dcardnum $dcardnum]

 uno_showwhodrew $UnoRobot

 set UnoHand($ThisPlayer) [uno_sorthand $UnoHand($ThisPlayer)]

 # look for card in hand
 set CardOk [uno_botplayertrycard]

 # bot plays drawn card or passes turn
 if {$CardOk > -1} {
  set pcard [lindex $UnoHand($ThisPlayer) $CardOk]
  uno_playactualcard $UnoRobot [uno_findcard $UnoRobot $CardOk $pcard] $CardOk $pcard 1
 } {
  uno_isdrawreset
  uno_nextplayer
  uno_showplaypass $UnoRobot $ThisPlayer
  uno_showcards $ThisPlayer $ThisPlayerIDX
 }
 return
}

#
# autoskip inactive players
#
proc UnoAutoSkip {} {
 global UnoMode ThisPlayer ThisPlayerIDX RoundRobin AutoSkipPeriod IsColorChange ColorPicker
 global UnoIDX UnoPlayers UnoDeck UnoHand UnoChan UnoSkipTimer UnoDebug UnoNickColor UnoPaused UnoDCCIDX UnoLastIdler
 global botnick

 if {($UnoMode != 2)||($UnoPaused != 0)} {return}

 set Idler $ThisPlayer
 set IdlerIDX $ThisPlayerIDX

 if {[uno_isrobot $ThisPlayerIDX]} {unolog "uno" "oops: Autoskip called while bot players turn"; return}

 if {[uno_timerexists UnoAutoSkip] != ""} {
  unolog "uno" "oops: Autoskip timer called, but already exists"
  return
 }

 set InChannel 0
 set uclist [chanlist $UnoChan]

 set pcount 0
 while {[lindex $uclist $pcount] != ""} {
  if {[lindex $uclist $pcount] == $Idler} {
   set InChannel 1
   break
  }
  incr pcount
 }

 if {!$InChannel || ($Idler == $UnoLastIdler)} {
  if {!$InChannel} {
   unomsg "[unonik $Idler]\003 left the channel and is removed from Uno"
  } {
   unomsg "[unonik $Idler]\003 has been idle twice in a row and is removed from Uno"
   set UnoLastIdler ""
  }
  if {$IsColorChange == 1} {
   if {$Idler == $ColorPicker} {
    # Make A Color Choice
    set cip [uno_pickcolor]
    unomsg "\0030,13 $Idler \003was picking a color : randomly selecting $cip"
    set IsColorChange 0
   } {
    unolog "uno" "oops: UnoAutoRemove color change set but $Idler not color picker"
   }
  }

  uno_nextplayer

  unomsg "[unonik $Idler]\003 was the current player, continuing with [unonik $ThisPlayer]"

  uno_showcards $ThisPlayer $ThisPlayerIDX

  set UnoPlayers [expr ($UnoPlayers -1)]

  # remove player from game and put cards back in deck
  if {$UnoPlayers > 1} {
   set RoundRobin [lreplace $RoundRobin $IdlerIDX $IdlerIDX]
   set UnoIDX [lreplace $UnoIDX $IdlerIDX $IdlerIDX]
   while {[llength $UnoHand($Idler)] > 0} {
    set pcard [lindex $UnoHand($Idler) 0]
    set UnoHand($Idler) [lreplace $UnoHand($Idler) 0 0]
    lappend UnoDeck $pcard
   }
   if [info exist UnoHand($Idler)] {unset UnoHand($Idler)}
   if [info exist UnoNickColor($Idler)] {unset UnoNickColor($Idler)}
   if [info exist UnoDCCIDX($Idler)] {unset UnoDCCIDX($Idler)}
  }

  switch $UnoPlayers {
   1 {
      uno_showwindefault $ThisPlayer
      UnoWin $ThisPlayer
      UnoCycle
     }
   0 {
      unochanmsg "\00306no players, no winner... cycling"
      UnoCycle
     }
   default {
      if {![uno_isrobot $ThisPlayerIDX]} {
       uno_autoskipreset $botnick
       uno_restartbotplayer
      }
     }
  }
  return
 }

 if {$UnoDebug > 0} {unolog "uno" "AutoSkip Player: $Idler"}

 unomsg "[unonik $Idler]\003 idle for \00313$AutoSkipPeriod \003minutes and is skipped"

 set UnoLastIdler $Idler

 # player was color picker
 if {$IsColorChange == 1} {
  if {$Idler == $ColorPicker} {
   # Make A Color Choice
   set cip [uno_pickcolor]
   unomsg "[unonik $Idler]\003 was picking a color : randomly selecting $cip"
   set IsColorChange 0
  } {
   unolog "uno" "UnoRemove: IsColorChange set but $Idler not ColorPicker"
  }
 }

 uno_nextplayer

 unomsg "[unonik $Idler]\003 was the current player, continuing with [unonik $ThisPlayer]"

 uno_showcards $ThisPlayer $ThisPlayerIDX

 if {[uno_isrobot $ThisPlayerIDX]} {
  uno_restartbotplayer
 }

 uno_autoskipreset $botnick
 return
}

#
# pause play
#
proc UnoPause {nick uhost hand chan txt} {
 global UnoChan UnoOpFlags UnoPaused

 if {![uno_isrunning $chan]} {return}

 if {([validuser $nick])&&([matchattr $nick $UnoOpFlags $UnoChan])} {
  if {!$UnoPaused} {
   set UnoPaused 1
   UnoUnbindCmds
   unochanmsg "\00304 paused \003by $nick"
  } {
   set UnoPaused 0
   UnoBindCmds
   uno_autoskipreset $nick
   unochanmsg "\00303 resumed \003by $nick"
  }
 }
}

#
# remove user from play
#
proc UnoRemove {nick uhost hand chan txt} {
 global UnoChan UnoCycleTime UnoIDX UnoPlayers ThisPlayer ThisPlayerIDX RoundRobin UnoDeck DiscardPile UnoHand IsColorChange ColorPicker UnoNickColor UnoOpFlags UnoDCCIDX

 if {![uno_isrunning $chan]} {return}

 regsub -all \[`,.!{}] $txt "" txt

 # allow ops to remove another player
 set UnoOpRemove 0

 if {[string length $txt] > 0} {
  if {([validuser $nick])&&([matchattr $nick $UnoOpFlags $UnoChan])} {
   set UnoOpRemove 1
   set UnoOpNick $nick
   set nick $txt
  } {
   return
  }
 }

 # remove player if found - put cards back to bottom of deck
 set pcount 0
 set PlayerFound 0
 while {[lindex $RoundRobin $pcount] != ""} {
  if {[string tolower [lindex $RoundRobin $pcount]] == [string tolower $nick]} {
   set PlayerFound 1
   set FoundIDX $pcount
   set nick [lindex $RoundRobin $pcount]
   break
  }
  incr pcount
 }

 if {!$PlayerFound} {return}

 if {$UnoOpRemove > 0} {
  unomsg "[unonik $nick]\003 was removed from uno by $UnoOpNick"
 } {
  unontc $nick "You are now removed from the current uno game."
  unomsg "[unonik $nick]\003 left Uno"
 }

 # player was color picker
 if {$IsColorChange == 1} {
  if {$nick == $ColorPicker} {
   # Make A Color Choice
   set cip [uno_pickcolor]
   unomsg "[unonik $nick]\003 was choosing a color... I randomly select $cip"
   set IsColorChange 0
  } {
   unolog "uno" "UnoRemove: IsColorChange set but $nick not ColorPicker"
  }
 }

 if {$nick == $ThisPlayer} {
  uno_nextplayer
  if {$UnoPlayers > 2} {
   unomsg "[unonik $nick]\003 was the current player, continuing with [unonik $ThisPlayer]"
  }
  uno_autoskipreset $nick
 }

 set UnoPlayers [expr ($UnoPlayers -1)]

 # remove player from game and put cards back in deck

 if {$UnoPlayers > 1} {
  set RoundRobin [lreplace $RoundRobin $FoundIDX $FoundIDX]
  set UnoIDX [lreplace $UnoIDX $FoundIDX $FoundIDX]
  while {[llength $UnoHand($nick)] > 0} {
   set pcard [lindex $UnoHand($nick) 0]
   set UnoHand($nick) [lreplace $UnoHand($nick) 0 0]
   lappend DiscardPile $pcard
  }
  if [info exist UnoHand($nick)] {unset UnoHand($nick)}
  if [info exist UnoNickColor($nick)] {unset UnoNickColor($nick)}
  if [info exist UnoDCCIDX($nick)] {unset UnoDCCIDX($nick)}
 }

 set pcount 0
 while {[lindex $RoundRobin $pcount] != ""} {
  if {[lindex $RoundRobin $pcount] == $ThisPlayer} {
   set ThisPlayerIDX $pcount
   break
  }
  incr pcount
 }

 if {$UnoPlayers == 1} {
  uno_showwindefault $ThisPlayer
  UnoWin $ThisPlayer
  UnoCycle
  return
 }

 uno_restartbotplayer

 if {!$UnoPlayers} {
  unochanmsg "no players, no winner... recycling"
  UnoCycle
 }
 return
}

#
# move to next player
#
proc uno_nextplayer {} {
 global ThisPlayer ThisPlayerIDX RoundRobin
 incr ThisPlayerIDX
 if {$ThisPlayerIDX >= [llength $RoundRobin]} {set ThisPlayerIDX 0}
 set ThisPlayer [lindex $RoundRobin $ThisPlayerIDX]
}

#
# set global PlayCard to chosen color and return colored card 
#
proc uno_getcolorcard {crd} {
 global PlayCard UnoRedCard UnoGreenCard UnoBlueCard UnoYellowCard
 set pcol [string range $crd 0 0]
 switch $pcol {
  "R" {set PlayCard "R"; return "$UnoRedCard\003" }
  "G" {set PlayCard "G"; return "$UnoGreenCard\003" }
  "B" {set PlayCard "B"; return "$UnoBlueCard\003" }
  "Y" {set PlayCard "Y"; return "$UnoYellowCard\003" }
 }
}

#
# returns 1 if color card, 0 if not
#
proc uno_iscolorcard {c} {
 switch $c {
  "R" {return 1}
  "G" {return 1}
  "B" {return 1}
  "Y" {return 1}
 }
 return 0
}

#
# pick a random color for skipped/removed players
#
proc uno_pickcolor {} {
 set ucolors "R G B Y"
 set pcol [lindex $ucolors [rand [llength $ucolors]]]
 return [uno_getcolorcard $pcol]
}

#
# robot player picks a color by checking hand for 1st color card
# found with matching color, else it picks a color at random
#
proc uno_botpickcolor {} {
 global UnoHand ThisPlayer ColorPicker

 set hlen [llength $UnoHand($ColorPicker)]

 # draw two
 set CardCount 0
 while {$CardCount < $hlen} {
  set thiscolor [string range [lindex $UnoHand($ColorPicker) $CardCount] 0 0]
  set thiscard [string range [lindex $UnoHand($ColorPicker) $CardCount] 1 1]
  if {([uno_iscolorcard $thiscolor])&&($thiscard == "D")} { return [uno_getcolorcard $thiscolor] }
  incr CardCount
 }

 # skip/reverse
 set CardCount 0
 while {$CardCount < $hlen} {
  set thiscolor [string range [lindex $UnoHand($ColorPicker) $CardCount] 0 0]
  set thiscard [string range [lindex $UnoHand($ColorPicker) $CardCount] 1 1]
  if {([uno_iscolorcard $thiscolor])&&(($thiscard == "S")||($thiscard == "R"))} { return [uno_getcolorcard $thiscolor] }
  incr CardCount
 }

 # number card
 set CardCount 0
 while {$CardCount < $hlen} {
  set thiscolor [string range [lindex $UnoHand($ColorPicker) $CardCount] 0 0]
  if {[uno_iscolorcard $thiscolor]} { return [uno_getcolorcard $thiscolor] }
  incr CardCount
 }

 # wild or wdf remain, pick color at random
 return [uno_pickcolor]
}

#
# timers
#

# set robot for next turn
proc uno_restartbotplayer {} {
 global UnoMode ThisPlayerIDX RobotRestartPeriod UnoBotTimer
 if {$UnoMode != 2} {return}
 if {![uno_isrobot $ThisPlayerIDX]} {return}
 set UnoBotTimer [utimer $RobotRestartPeriod UnoRobotPlayer]
}

# reset autoskip timer
proc uno_autoskipreset {nick} {
 global AutoSkipPeriod UnoMode UnoSkipTimer UnoLastIdler
 catch {killtimer $UnoSkipTimer}
 if {$nick == $UnoLastIdler} { set UnoLastIdler "" }
 if {$UnoMode == 2} { set UnoSkipTimer [timer $AutoSkipPeriod UnoAutoSkip] }
}

#
# channel triggers
#

# game help
proc UnoCmds {nick uhost hand chan txt} {
 global UnoLogo
 if {![uno_ischan $chan]} {return}
 unogntc $nick "$UnoLogo Commands: !uno !stop !remove \[nick\] !unowon \[nick\] !unocmds"
 unogntc $nick "$UnoLogo Stats: !unotop10 \[games\|wins\|21\] !unotop3last !unostats !unorecords"
 unogntc $nick "$UnoLogo Card Commands: jo=join pl=play dr=draw pa=pass co=color"
 unogntc $nick "$UnoLogo Chan Commands: ca=cards cd=card tu=turn od=order ct=count st=stats ti=time"
 return
}

# game version
proc UnoVersion {nick uhost hand chan txt} {
 global UnoVersion
 unochanmsg "$UnoVersion by Marky \003"
 return
}

# current player order
proc UnoOrder {nick uhost hand chan txt} {
 global UnoPlayers RoundRobin
 if {![uno_isrunning $chan]} {return}
 unochanmsg "Player order: \00314$RoundRobin\003"
 return
}

# game running time
proc UnoTime {nick uhost hand chan txt} {
 global UnoLogo
 if {![uno_isrunning $chan]} {return}
 unochanmsg "Game time \00314[UnoDuration [uno_gametime]] \003"
 return
}

# show player what cards in hand
proc UnoShowCards {nick uhost hand chan txt} {
 global UnoHand ThisPlayerIDX

 if {![uno_isrunning $chan]} {return}

 if ![info exist UnoHand($nick)] { return }

 set UnoHand($nick) [uno_sorthand $UnoHand($nick)]

 set Card [uno_cardcolorall $nick]

 if {![uno_isrobot $ThisPlayerIDX]} { unontc $nick "$Card\003" }

 return
}

# show current player
proc UnoTurn {nick uhost hand chan txt} {
 global ThisPlayer RoundRobin UnoMode
 if {![uno_isrunning $chan]} {return}
 if {[llength $RoundRobin] < 1 } {return}
 unochanmsg "Current player: \00314$ThisPlayer\003"
 return
}

# show current top card
proc UnoTopCard {nick uhost hand chan txt} {
 global PlayCard
 if {![uno_isrunning $chan]} {return}
 set Card [uno_cardcolor $PlayCard]
 unochanmsg "Card in play: $Card"
 return
}

# card stats
proc UnoCardStats {nick uhost hand chan txt} {
 global CardStats
 if {![uno_isrunning $chan]} {return}
 unochanmsg "Played:\00314$CardStats(played)\003"
 return
}

# card count
proc UnoCardCount {nick uhost hand chan txt} {
 global RoundRobin UnoHand
 if {![uno_isrunning $chan]} {return}
 set ordcnt 0
 set crdcnt ""
 while {[lindex $RoundRobin $ordcnt] != ""} {
  set cp [lindex $RoundRobin $ordcnt]
  set cc [llength $UnoHand($cp)]
  append crdcnt "\00310 $cp \00306 $cc cards "
  incr ordcnt
 }
 unomsg "$crdcnt\003"
 return
}

# player's score
proc UnoWon {nick uhost hand chan txt} {
 global UnoScoreFile UnoPointsName

 if {![uno_ischan $chan]} {return}

 regsub -all \[`,.!] $txt "" txt

 if {![string length $txt]} {set txt $nick}

 set scorer [string tolower $txt]

 set pflag 0

 set f [open $UnoScoreFile r]
 while {[gets $f sc] != -1} {
  set cnick [string tolower [lindex [split $sc] 0]]
  if {$cnick == $scorer} {
   set winratio [format "%4.1f" [expr [lindex $sc 2] /[lindex $sc 1]]]
   set pmsg "\00306[lindex [split $sc] 0] \003 [lindex $sc 2] $UnoPointsName in [lindex $sc 1] games \($winratio p\/g\)"
   set pflag 1
  }
 }
 close $f

 if {!$pflag} {
  set pmsg "\00306$txt\003 no score"
 }
 unochanmsg "$pmsg"
 return
}

# current top10 list
proc UnoTopTen {nick uhost hand chan txt} {
 if {![uno_ischan $chan]} {return}
 regsub -all \[`,.!{}\ ] $txt "" txt
 set txt [string tolower [string range $txt 0 10]]
 switch $txt {
  "won" {set mode 1}
  "games" {set mode 0}
  "points" {set mode 1}
  "21" {set mode 2}
  "blackjack" {set mode 2}
  default {set mode 1}
 }
 UnoTop10 $mode
 return
}

# last month's top3
proc UnoTopThreeLast {nick uhost hand chan txt} {
 if {![uno_ischan $chan]} {return}
 UnoLastMonthTop3 $nick $uhost $hand $chan 0
 UnoLastMonthTop3 $nick $uhost $hand $chan 1
 return
}

# month's stats
proc UnoPlayStats {nick uhost hand chan txt} {
 global UnoFast UnoHigh UnoPlayed UnoPointsName
 if {![uno_ischan $chan]} {return}
 unochanmsg "Current record holders"
 set msg "\00306Fast:\003 [lindex [split $UnoFast] 0] \002[UnoDuration [lindex $UnoFast 1]]\002  "
 append msg "\00306High:\003 [lindex [split $UnoHigh] 0] \002[lindex $UnoHigh 1]\002 $UnoPointsName  "
 append msg "\00306Played:\003 [lindex [split $UnoPlayed] 0] \002[lindex $UnoPlayed 1]\002 Cards"
 unochanmsg "$msg"
 return
}

# all-time records
proc UnoRecords {nick uhost hand chan txt} {
 global UnoRecordFast UnoRecordHigh UnoRecordCard UnoRecordWins UnoRecordPlayed
 if {![uno_ischan $chan]} {return}
 unochanmsg "All-Time Records"
 unochanmsg "\00306Points:\003 $UnoRecordCard \00306 Games:\003 $UnoRecordWins \00306 Fast:\003 [lindex $UnoRecordFast 0] [UnoDuration [lindex $UnoRecordFast 1]] \00306 High Score:\003 $UnoRecordHigh \00306 Cards Played:\003 $UnoRecordPlayed \003"
 return
}

# current row (streak)
proc UnoCurrentRow {nick uhost hand chan txt} {
 global UnoLastWinner UnoWinsInARow
 if {![uno_ischan $chan]} {return}
 if {($UnoLastWinner != "")&&($UnoWinsInARow > 0)} {
  switch ($UnoWinsInARow) {
   1 { unochanmsg "\0036$UnoLastWinner \003 has won \0030,6 $UnoWinsInARow game \003" }
   default { unochanmsg "\0033$UnoLastWinner \003 is on a \0030,6 $UnoWinsInARow game streak \003" }
  }
 }
 return
}

# month top10
proc UnoTop10 {mode} {
 global UnoScoreFile unsortedscores UnoPointsName UnoRobot

 if {($mode < 0)||($mode > 2)} {set mode 0}

 switch $mode {
  0 {set winners "Top10 Game Wins "}
  1 {set winners "Top10 $UnoPointsName "}
  2 {set winners "Top10 Blackjacks "}
 }

 if ![file exists $UnoScoreFile] {
  set f [open $UnoScoreFile w]
  puts $f "$UnoRobot 0 0 0"
  unochanmsg "\0034Uno scores reset"
  close $f
  return
 } {
  unomsg "$winners"
  set winners ""
 }

 if [info exists unsortedscores] {unset unsortedscores}
 if [info exists top10] {unset top10}

 set f [open $UnoScoreFile r]
 while {[gets $f s] != -1} {
  switch $mode {
   0 {set unsortedscores([lindex [split $s] 0]) [lindex $s 1]}
   1 {set unsortedscores([lindex [split $s] 0]) [lindex $s 2]}
   2 {set unsortedscores([lindex [split $s] 0]) [lindex $s 3]}
  }
 }
 close $f

 for {set s 0} {$s < 10} {incr s} {
  set top10($s) "Nobody 0"
 }

 set s 0
 foreach n [lsort -decreasing -command uno_sortscores [array names unsortedscores]] {
  set top10($s) "$n $unsortedscores($n)"
  incr s
 }

 for {set s 0} {$s < 10} {incr s} {
  if {[llength [lindex $top10($s) 0]] > 0} {
   if {[lindex [split $top10($s)] 0] != "Nobody"} {
    append winners "\0030,6 #[expr $s +1] \0030,10 [lindex [split $top10($s)] 0] [lindex $top10($s) 1] "
   }
  }
 }

 unomsg "$winners \003"
 return
}

# last month's top3
proc UnoLastMonthTop3 {nick uhost hand chan txt} {
 global UnoLastMonthCards UnoLastMonthGames UnoPointsName
 if {![uno_ischan $chan]} {return}
 if {!$txt} {
  if [info exists UnoLastMonthCards] {
   set UnoTop3 ""
   unochanmsg "Last Month's Top 3 $UnoPointsName Winners"
   for { set s 0} { $s < 3 } { incr s} {
    append UnoTop3 "\0030,6 #[expr $s +1] \0030,10 $UnoLastMonthCards($s) "
   }
   unomsg "$UnoTop3"
  }
 } {
  if [info exists UnoLastMonthGames] {
   set UnoTop3 ""
   unochanmsg "Last Month's Top 3 Game Winners"
   for { set s 0} { $s < 3 } { incr s} {
    append UnoTop3 "\0030,6 #[expr $s +1] \0030,10 $UnoLastMonthGames($s) "
   }
   unomsg "$UnoTop3"
  }
 }
}

#
# scores/records
#

# read score file
proc UnoReadScores {} {
 global unogameswon unoptswon unoblackjackswon UnoScoreFile UnoRobot

 if [info exists unogameswon] { unset unogameswon }
 if [info exists unoptswon] { unset unoptswon }
 if [info exists unoblackjackswon] { unset unoblackjackswon }

 if ![file exists $UnoScoreFile] {
  set f [open $UnoScoreFile w]
  puts $f "$UnoRobot 0 0 0"
  close $f
 }

 set f [open $UnoScoreFile r]
 while {[gets $f s] != -1} {
  set unogameswon([lindex [split $s] 0]) [lindex $s 1]
  set unoptswon([lindex [split $s] 0]) [lindex $s 2]
  set unoblackjackswon([lindex [split $s] 0]) [lindex $s 3]
 }
 close $f

 return
}

# clear top10 and write monthly scores
proc UnoNewMonth {min hour day month year} {
 global unsortedscores unogameswon unoptswon unoblackjackswon UnoLastMonthCards UnoLastMonthGames UnoScoreFile UnoRobot
 global UnoFast UnoHigh UnoPlayed UnoRecordFast UnoRecordHigh UnoRecordPlayed UnoRecordCard UnoRecordWins

 set lmonth [UnoLastMonthName $month]

 unochanmsg "\00306Clearing monthly scores"

 set UnoMonthFileName "$UnoScoreFile.$lmonth"

 # read current scores
 UnoReadScores

 # write to old month file
 if ![file exists $UnoMonthFileName] {
  set f [open $UnoMonthFileName w]
  foreach n [array names unogameswon] {
   puts $f "$n $unogameswon($n) $unoptswon($n) $unoblackjackswon($n)"
  }
  close $f
 }

 # find top 3 card holders and game winners
 set mode 0 

 while {$mode < 2} {
  if [info exists unsortedscores] {unset unsortedscores}
  if [info exists top10] {unset top10}

  set f [open $UnoScoreFile r]
  while {[gets $f s] != -1} {
   switch $mode {
    0 {set unsortedscores([lindex [split $s] 0]) [lindex $s 1]}
    1 {set unsortedscores([lindex [split $s] 0]) [lindex $s 2]}
   }
  }
  close $f

  set s 0
  foreach n [lsort -decreasing -command uno_sortscores [array names unsortedscores]] {
   set top10($s) "$n $unsortedscores($n)"
   incr s
  }

  for {set s 0} {$s < 3} {incr s} {
   if {[lindex $top10($s) 1] > 0} {
    switch $mode {
     0 {set UnoLastMonthGames($s) "[lindex [split $top10($s)] 0] [lindex $top10($s) 1]"}
     1 {set UnoLastMonthCards($s) "[lindex [split $top10($s)] 0] [lindex $top10($s) 1]"}
    }
   } {
    switch $mode {
     0 {set UnoLastMonthGames($s) "Nobody 0"}
     1 {set UnoLastMonthCards($s) "Nobody 0"}
    }
   }
  }
  incr mode
 }

 # update records
 if {[lindex $UnoFast 1] < [lindex $UnoRecordFast 1]} {set UnoRecordFast $UnoFast}
 if {[lindex $UnoHigh 1] > [lindex $UnoRecordHigh 1]} {set UnoRecordHigh $UnoHigh}
 if {[lindex $UnoPlayed 1] > [lindex $UnoRecordPlayed 1]} {set UnoRecordPlayed $UnoPlayed}
 if {[lindex $UnoLastMonthCards(0) 1] > [lindex $UnoRecordCard 1]} {set UnoRecordCard $UnoLastMonthCards(0)}
 if {[lindex $UnoLastMonthGames(0) 1] > [lindex $UnoRecordWins 1]} {set UnoRecordWins $UnoLastMonthGames(0)}

 # wipe last months records
 set UnoFast "$UnoRobot 60"
 set UnoHigh "$UnoRobot 100"
 set UnoPlayed "$UnoRobot 100"

 # save top3 and records to config file
 UnoWriteCFG

 # wipe this months score file
 set f [open $UnoScoreFile w]
 puts $f "$UnoRobot 0 0 0"
 close $f

 unolog "uno" "cleared monthly scores"
 return
}

# update score of winning player
proc UnoUpdateScore {winner cardtotals blackjack} {
 global unogameswon unoptswon unoblackjackswon UnoScoreFile

 UnoReadScores

 if {[info exists unogameswon($winner)]} {
  incr unogameswon($winner) 1
 } {
  set unogameswon($winner) 1
 }

 if {[info exists unoptswon($winner)]} {
  incr unoptswon($winner) $cardtotals
 } {
  set unoptswon($winner) $cardtotals
 }

 if {$blackjack} {
  if {[info exists unoblackjackswon($winner)]} {
   incr unoblackjackswon($winner) 1
  } {
   set unoblackjackswon($winner) 1
  }
 } {
  if {![info exists unoblackjackswon($winner)]} {
   set unoblackjackswon($winner) 0
  }
 }

 set f [open $UnoScoreFile w]
 foreach n [array names unogameswon] {
  puts $f "$n $unogameswon($n) $unoptswon($n) $unoblackjackswon($n)"
 }
 close $f

 return
}

# display winner and game statistics
proc UnoWin {winner} {
 global UnoHand ThisPlayer RoundRobin UnoPointsName CardStats UnoMode UnoCycleTime
 global UnoFast UnoHigh UnoPlayed UnoBonus UnoWinDefault UnoDCCIDX UnoRobot UnoLastWinner UnoWinsInARow
 
 # get time game finished
 set UnoTime [uno_gametime]

 set cardtotals 0
 set UnoMode 3
 set ThisPlayerIDX 0
 set needCFGWrite 0
 set isblackjack 0
 set cardtake 0

 # colour winner's nick
 set cnick [unonik $winner]

 #unomsg "\00306Card Totals"

 # total up all player's cards
 while {$ThisPlayerIDX != [llength $RoundRobin]} {
  set Card ""
  set ThisPlayer [lindex $RoundRobin $ThisPlayerIDX]
  if [info exist UnoDCCIDX($ThisPlayer)] {unset UnoDCCIDX($ThisPlayer)}
  if {$ThisPlayer != $winner} {
   set ccount 0
   while {[lindex $UnoHand($ThisPlayer) $ccount] != ""} {
    set cardtotal [lindex $UnoHand($ThisPlayer) $ccount]
    set c1 [string range $cardtotal 0 0]
    set c2 [string range $cardtotal 1 1]
    set cardtotal 0

    if {$c1 == "W"} {
     set cardtotal 50
    } {
     switch $c2 {
      "S" {set cardtotal 20}
      "R" {set cardtotal 20}
      "D" {set cardtotal 20}
      default {set cardtotal $c2}
     }
    }
    set cardtotals [expr $cardtotals + $cardtotal]
    incr ccount
   }
   set Card [uno_cardcolorall $ThisPlayer]
   unochanmsg "[unonik $ThisPlayer] \003 $Card"
   #unochanmsg "[unonik $ThisPlayer] \003\[$ccount\] $Card"
   incr cardtake $ccount
  }
  incr ThisPlayerIDX
 }

 set bonus 0
 set bbonus 0

 # bonuses not given for win by default
 if {$UnoWinDefault != 1} {
  set HighScore [lindex $UnoHigh 1]
  set HighPlayed [lindex $UnoPlayed 1]
  set FastRecord [lindex $UnoFast 1]

  # out with 21 adds blackjack bonus
  if {$cardtotals == 21} {
   set bbonus [expr $UnoBonus /2]
   unochanmsg "$cnick\003 goes out on 21! \0034\002$bbonus\002\003 Blackjack Bonus $UnoPointsName"
   incr bonus $bbonus
   set isblackjack 1
  }

  # high score record
  if {$cardtotals > $HighScore} {
   unochanmsg "$cnick\003 broke the \002High Score Record\002 \00304$UnoBonus\003 bonus $UnoPointsName"
   set UnoHigh "$winner $cardtotals"
   incr bonus $UnoBonus
  }

  # played cards record
  if {$CardStats(played) > $HighPlayed} {
   unochanmsg "$cnick\003 broke the \002Most Cards Played Record\002 \00304$UnoBonus\003 bonus $UnoPointsName"
   set UnoPlayed "$winner $CardStats(played)"
   incr bonus $UnoBonus
  }

  # fast game record
  if {($UnoTime < $FastRecord)&&($winner != $UnoRobot)} {
   unochanmsg "$cnick\003 broke the \002Fast Game Record\002 \00304$UnoBonus\003 bonus $UnoPointsName"
   incr bonus $UnoBonus
   set UnoFast "$winner $UnoTime"
  }
 }

 # win streak bonus
 if {$winner == $UnoLastWinner} {
  incr UnoWinsInARow
  set RowMod [expr {$UnoWinsInARow %3}]
  if {!$RowMod} {
   set RowBonus [expr int((pow(2,($UnoWinsInARow/3)-1)*($UnoBonus/4)))]
   unochanmsg "$cnick\003 has won \00314\002$UnoWinsInARow\002\003 in a row and earns \00304\002$RowBonus\002\003 bonus $UnoPointsName"
   incr bonus $RowBonus
  }
 } {
  if {($UnoLastWinner != "")&&($UnoWinsInARow > 1)} {
   unochanmsg "$cnick\003 has put an end to \002$UnoLastWinner\'\s\002 streak of \002$UnoWinsInARow\002 wins"
  }
  set UnoLastWinner $winner
  set UnoWinsInARow 1
 }

 # show winner
 set msg "$cnick\003 wins \00314\002$cardtotals\002\003 $UnoPointsName by taking \00314\002$cardtake\002\003 cards"

 # add bonus
 if {$bonus} {
  incr cardtotals $bonus
  set needCFGWrite 1
  append msg "  total:\00303\002$cardtotals\002\003 $UnoPointsName"
 }

 unochanmsg "$msg"

 # show game stats
 unochanmsg "\00314$CardStats(played)\003 cards played in \00314[UnoDuration $UnoTime]\003"

 # write scores
 UnoUpdateScore $winner $cardtotals $isblackjack

 # write records
 if {$needCFGWrite} {UnoWriteCFG}

 return
}

# reshuffle deck
proc UnoShuffle {cardsneeded} {
 global UnoDeck DiscardPile

 # no need in shuffling if more cards remain than needed
 if {[llength $UnoDeck] >= $cardsneeded} { return }

 unochanmsg "\0034\002Re-shuffling deck\002"

 set DeckLeft 0
 while {$DeckLeft < [llength $UnoDeck]} {
  lappend DiscardPile [lindex $UnoDeck $DeckLeft]
  incr DeckLeft
 }

 set UnoDeck ""
 set NewDeckSize [llength $DiscardPile]

 while {[llength $UnoDeck] != $NewDeckSize} {
  set pcardnum [rand [llength $DiscardPile]]
  set pcard [lindex $DiscardPile $pcardnum]
  lappend UnoDeck $pcard
  set DiscardPile [lreplace $DiscardPile $pcardnum $pcardnum]
 }

 return
}

# read config file
proc UnoReadCFG {} {
 global UnoChan UnoCFGFile UnoLastMonthCards UnoLastMonthGames UnoPointsName UnoScoreFile UnoStopAfter UnoBonus
 global UnoFast UnoHigh UnoPlayed UnoRecordHigh UnoRecordFast UnoRecordCard UnoRecordWins UnoRecordPlayed UnoWildDrawTwos UnoWDFAnyTime UnoAds

 if {[file exist $UnoCFGFile]} {
  set f [open $UnoCFGFile r]
  while {[gets $f s] != -1} {
   set kkey [string tolower [lindex [split $s "="] 0]]
   set kval [lindex [split $s "="] 1]
   switch $kkey {
    channel {set UnoChan $kval}
    points {set UnoPointsName $kval}
    scorefile {set UnoScoreFile $kval}
    stopafter {set UnoStopAfter $kval}
    wilddrawtwos {set UnoWildDrawTwos $kval}
    wdfanytime {set UnoWDFAnyTime $kval}
    lastmonthcard1 {set UnoLastMonthCards(0) $kval}
    lastmonthcard2 {set UnoLastMonthCards(1) $kval}
    lastmonthcard3 {set UnoLastMonthCards(2) $kval}
    lastmonthwins1 {set UnoLastMonthGames(0) $kval}
    lastmonthwins2 {set UnoLastMonthGames(1) $kval}
    lastmonthwins3 {set UnoLastMonthGames(2) $kval}
    ads {set UnoAds $kval}
    fast {set UnoFast $kval}
    high {set UnoHigh $kval}
    played {set UnoPlayed $kval}
    bonus {set UnoBonus $kval}
    recordhigh {set UnoRecordHigh $kval}
    recordfast {set UnoRecordFast $kval}
    recordcard {set UnoRecordCard $kval}
    recordwins {set UnoRecordWins $kval}
    recordplayed {set UnoRecordPlayed $kval}
   }
  }
  close $f
  if {$UnoStopAfter < 0} {set UnoStopAfter 0}
  if {$UnoBonus <= 0} {set UnoBonus 100}
  if {($UnoWildDrawTwos < 0)||($UnoWildDrawTwos > 1)} {set UnoWildDrawTwos 0}
  if {($UnoAds < 0)||($UnoAds > 1)} {set UnoAds 1}
  return
 }
 putcmdlog "\[Uno\] config file $UnoCFGFile not found... saving defaults"
 UnoWriteCFG
 return
}

# write config file
proc UnoWriteCFG {} {
 global UnoChan UnoCFGFile UnoLastMonthCards UnoLastMonthGames UnoPointsName UnoScoreFile UnoStopAfter UnoBonus
 global UnoFast UnoHigh UnoPlayed UnoRecordHigh UnoRecordFast UnoRecordCard UnoRecordWins UnoRecordPlayed UnoWildDrawTwos UnoWDFAnyTime UnoAds

 set f [open $UnoCFGFile w]

 puts $f "# This file is automatically overwritten"
 puts $f "Channel=$UnoChan"
 puts $f "Points=$UnoPointsName"
 puts $f "ScoreFile=$UnoScoreFile"
 puts $f "StopAfter=$UnoStopAfter"
 puts $f "WildDrawTwos=$UnoWildDrawTwos"
 puts $f "WDFAnyTime=$UnoWDFAnyTime"
 puts $f "Ads=$UnoAds"
 puts $f "LastMonthCard1=$UnoLastMonthCards(0)"
 puts $f "LastMonthCard2=$UnoLastMonthCards(1)"
 puts $f "LastMonthCard3=$UnoLastMonthCards(2)"
 puts $f "LastMonthWins1=$UnoLastMonthGames(0)"
 puts $f "LastMonthWins2=$UnoLastMonthGames(1)"
 puts $f "LastMonthWins3=$UnoLastMonthGames(2)"
 puts $f "Fast=$UnoFast"
 puts $f "High=$UnoHigh"
 puts $f "Played=$UnoPlayed"
 puts $f "Bonus=$UnoBonus"
 puts $f "RecordHigh=$UnoRecordHigh"
 puts $f "RecordFast=$UnoRecordFast"
 puts $f "RecordCard=$UnoRecordCard"
 puts $f "RecordWins=$UnoRecordWins"
 puts $f "RecordPlayed=$UnoRecordPlayed"

 close $f
 return
}

# score advertiser
proc UnoScoreAdvertise {} {
 global UnoChan UnoAdNumber UnoRobot

 switch $UnoAdNumber {
  0 {UnoTop10 1}
  1 {UnoLastMonthTop3 $UnoRobot none none $UnoChan 0}
  2 {UnoTop10 0}
  3 {UnoRecords $UnoRobot none none $UnoChan ""}
  4 {UnoTop10 2}
  5 {UnoPlayed $UnoRobot none none $UnoChan ""}
  6 {UnoHighScore $UnoRobot none none $UnoChan ""}
  7 {UnoTopFast $UnoRobot none none $UnoChan ""}
 }

 incr UnoAdNumber

 if {$UnoAdNumber > 7} {set UnoAdNumber 0}

 return
}

#
# misc utility functions
#

# sort cards in hand
proc uno_sorthand {playerhand} {
 set uhand [lsort -dictionary $playerhand]
 return $uhand
}

# color all cards in hand
proc uno_cardcolorall {cplayer} {
 global UnoHand
 set ccard ""
 set ccount 0
 set hcount [llength $UnoHand($cplayer)]
 while {$ccount != $hcount} {
  append ccard [uno_cardcolor [lindex $UnoHand($cplayer) $ccount]]
  incr ccount
 }
 return $ccard
}

# color a single card
proc uno_cardcolor {pcard} {
 global UnoRedCard UnoGreenCard UnoBlueCard UnoYellowCard UnoSkipCard UnoReverseCard UnoDrawTwoCard
 global UnoWildCard UnoWildDrawFourCard
  set c1 [string range $pcard 1 1]
  switch [string range $pcard 0 0] {
   "W" {
     if {$c1 == "D"} {
      set cCard $UnoWildDrawFourCard
     } {	
      set cCard $UnoWildCard
     }
     return $cCard
    }
   "R" { set cCard $UnoRedCard }
   "G" { set cCard $UnoGreenCard }
   "B" { set cCard $UnoBlueCard }
   "Y" { set cCard $UnoYellowCard }
   default { set cCard "" }
  }
  switch $c1 {
   "S" { append cCard $UnoSkipCard }
   "R" { append cCard $UnoReverseCard }
   "D" { append cCard $UnoDrawTwoCard }
   default { append cCard "$c1 \003 " }
  }
  return $cCard
}

# check if player has uno
proc uno_checkuno {cplayer} {
 global UnoHand
 if {[llength $UnoHand($cplayer)] > 1} {return}
 set has_uno "\002\00309H\00312a\00313s \00309U\00312n\00313o\00308! \002\003"
 unomsg "\001ACTION says [unonik $cplayer] $has_uno\001"
 return
}

# show player what cards they have
proc uno_showcards {cplayer cplayeridx} {
 global UnoIDX
 if {[uno_isrobot $cplayeridx]} {return}
 unontc [lindex $UnoIDX $cplayeridx] "[uno_cardcolorall $cplayer]"
}

# check if this is the robot player
proc uno_isrobot {cplayeridx} {
 global RoundRobin UnoRobot UnoMaxNickLen
 if {[string range [lindex $RoundRobin $cplayeridx] 0 $UnoMaxNickLen] != $UnoRobot} {return 0}
 return 1
}

# check if timer exists
proc uno_timerexists {cmd} {
 foreach i [timers] {
  if {![string compare $cmd [lindex $i 1]]} then {
   return [lindex $i 2]
  }
 }
 return
}

# sort scores
proc uno_sortscores {s1 s2} {
 global unsortedscores
 if {$unsortedscores($s1) <  $unsortedscores($s2)} {return -1}
 if {$unsortedscores($s1) == $unsortedscores($s2)} {return 0}
 if {$unsortedscores($s1) >  $unsortedscores($s2)} {return 1}
}

# calculate game running time
proc uno_gametime {} {
 global UnoStartTime
 set UnoCurrentTime [unixtime]
 set gt [expr ($UnoCurrentTime - $UnoStartTime)]
 return $gt
}

# colorize nickname
proc unonik {nick} {
 global UnoNickColor
 return "\003$UnoNickColor($nick)$nick"
}
proc unocolornick {pnum} {
 global UnoNickColors
 set c [lindex $UnoNickColors [expr $pnum-1]]
 set nik [format "%02d" $c]
 return $nik
}

# ratio of two numbers
proc unoget_ratio {num den} {
 set n 0.0
 set d 0.0
 set n [expr $n +$num]
 set d [expr $d +$den]
 if {!$d} {return 0}
 set ratio [expr (($n /$d) *100.0)]
 return $ratio
}

# name of last month
proc UnoLastMonthName {month} {
 switch $month {
  00 {return "Dec"}
  01 {return "Jan"}
  02 {return "Feb"}
  03 {return "Mar"}
  04 {return "Apr"}
  05 {return "May"}
  06 {return "Jun"}
  07 {return "Jul"}
  08 {return "Aug"}
  09 {return "Sep"}
  10 {return "Oct"}
  11 {return "Nov"}
  default {return "???"}
 }
}

# pad a string with spaces
proc unostrpad {str len} {
 set slen [string length $str]
 if {$slen > $len} {return $str}
 while {$slen < $len} {
  append str " "
  incr slen
 }
 return $str
}

# time interval in min and sec
proc UnoDuration {sec} {
  set s ""
  if {$sec >= 3600} {
   set tmp [expr $sec / 3600]
   set s [format "%s\002%d\002h:" $s $tmp]
   set sec [expr $sec - ($tmp*3600)]
  }
  if {$sec >= 60} {
   set tmp [expr $sec / 60]
   set s [format "%s\002%d\002m:" $s $tmp]
   set sec [expr $sec - ($tmp*60)]
  }
  if {$sec > 0} {
   set tmp $sec
   set s [format "%s\002%d\002s" $s $tmp]
  }
  return $s
}

#
# game messages
#

# played card
proc uno_showplaycard {who crd nplayer} {
 unomsg "[unonik $who]\003 plays $crd \003to [unonik $nplayer]"
}

# played draw card
proc uno_showplaydraw {who crd dplayer nplayer} {
 unomsg "[unonik $who]\003 plays $crd [unonik $dplayer]\003 draws \002two cards\002 and skips to [unonik $nplayer]"
}

# played wild card
proc uno_showplaywild {who chooser} {
 global UnoWildCard
 unomsg "[unonik $who]\003 plays $UnoWildCard choose a color [unonik $chooser]"
}

# played wild draw four
proc uno_showplaywildfour {who skipper chooser} {
 global UnoWildDrawFourCard
 unomsg "[unonik $who]\003 plays $UnoWildDrawFourCard [unonik $skipper]\003 draws \002four cards\002 and is skipped... Choose a color [unonik $chooser]"
}

# played skip card
proc uno_showplayskip {who crd skipper nplayer} {
 unomsg "[unonik $who]\003 plays $crd\003 and skips [unonik $skipper]\003 to [unonik $nplayer]"
}

# who drew a card
proc uno_showwhodrew {who} {
 unomsg "[unonik $who]\003 \002drew\002 a card"
}

# player passes a turn
proc uno_showplaypass {who nplayer} {
 unomsg "[unonik $who]\003 \002passes\002 to [unonik $nplayer]"
}

# bot plays wild card
proc uno_showbotplaywild {who chooser ncolr nplayer} {
 global UnoWildCard
 unomsg "[unonik $who]\003 plays $UnoWildCard and chooses $ncolr \003 Current player [unonik $nplayer]"
}

# bot plays wild draw four
proc uno_showbotplaywildfour {who skipper chooser choice nplayer} {
 global UnoWildDrawFourCard
 unomsg "[unonik $who]\003 plays $UnoWildDrawFourCard [unonik $skipper]\003 draws \002four cards\002 and is skipped. [unonik $chooser]\003 chooses $choice\003 Current player [unonik $nplayer]"
}

# show a player what they drew
proc uno_showdraw {idx crd} {
 global UnoIDX
 if {[uno_isrobot $idx]} {return}
 unontc [lindex $UnoIDX $idx] "Draw $crd"
}

# show win 
proc uno_showwin {who crd} {
 global UnoLogo
 unomsg "[unonik $who]\003 plays $crd and \002\00309W\00312i\00313n\00308s\002 $UnoLogo"
}

# show win by default
proc uno_showwindefault {who} {
 global UnoWinDefault UnoLogo
 unomsg "[unonik $who] \002\00309W\00312i\00313n\00308s $UnoLogo \002by default"
 set UnoWinDefault 1
}


#
# channel and dcc output
#

proc unomsg {what} {
 global UnoChan
 putquick "PRIVMSG $UnoChan :$what"
}

proc unochanmsg {what} {
 global UnoChan UnoLogo
 putquick "PRIVMSG $UnoChan :$UnoLogo $what"
}

proc unogntc {who what} {
 global UnoNTC
 putquick "$UnoNTC $who :$what"
}

proc unontc {who what} {
 global UnoNTC UnoDCCIDX
 if {$UnoDCCIDX($who) != -1} {
  putdcc $UnoDCCIDX($who) $what
 } {
  putquick "$UnoNTC $who :$what"
 }
}

proc unolog {who what} {
 putcmdlog "\[$who\] $what"
}

#
# dcc routines
#

proc unologin:dcc {hand idx} {
  global UnoChan UnoOn UnoDCCIDX RoundRobin

  if ![handonchan $hand $UnoChan] {return 0}

  set tnick [hand2nick $hand $UnoChan]
  if {($tnick == "")||($tnick == "*")} {return 0}
  if ![info exist UnoDCCIDX($tnick)] {return 0}

  set pcount 0
  while {[lindex $RoundRobin $pcount] != ""} {
   set pnick [lindex $RoundRobin $pcount]
   if {$pnick == $tnick} {
    if {[info exist UnoDCCIDX($pnick)]} {
     set UnoDCCIDX($pnick) $idx
     unolog "Uno" "$pnick on new dcc socket $idx"
     break
    }
   }
   incr pcount
  }
  return 0
}

proc unologout:dcc {hand idx} {
  global UnoChan UnoDCCIDX party-chan party-just-quit
  if {[info exists party-just-quit] && ${party-just-quit} == $hand} {unset party-just-quit ; return 0}
  if ![handonchan $hand $UnoChan] {return 0}
  set tnick [hand2nick $hand $UnoChan]
  if {($tnick == "")||($tnick == "*")} {return 0}
  if {[info exist UnoDCCIDX($tnick)]} {
   unolog "Uno" "$tnick left dcc \(resuming channel message mode\)"
   set UnoDCCIDX($tnick) -1
  }
}

proc unologout:filt {idx text} {
  global UnoChan UnoDCCIDX party-chan party-just-quit
  set hand [idx2hand $idx]
  set party-just-quit $hand
  set tnick [hand2nick $hand]
  if {($tnick == "")||($tnick == "*")} {return $text}
  if {[info exist UnoDCCIDX($tnick)]} {
   unolog "Uno" "$tnick left dcc \(resuming channel message mode\)"
   set UnoDCCIDX($tnick) -1
  }
  return $text
}

# show all players cards
proc dccunohands {hand idx txt} {
 global UnoHand RoundRobin
 set n 0
 while {$n != [llength $RoundRobin]} {
  set un [lindex $RoundRobin $n]
  unolog $un [uno_sorthand $UnoHand($un)]
  incr n
 }
}

# write configuration
proc dcc_unowriteconfig {hand idx txt} {
 unolog "$hand" "writing current uno config"
 UnoWriteCFG
 return
}

# rehash configuration
proc dcc_unorehash {hand idx txt} {
 unolog "$hand" "rehashing uno config"
 UnoReadCFG
 return
}

# set points name
proc dcc_unopoints {hand idx txt} {
 global UnoPointsName
 set pn [string trim $txt]
 if {[string length $pn] > 2} {
  set UnoPointsName $pn
  unolog "$hand" "uno points set to: $UnoPointsName"
 }
 return
}

UnoReadCFG

UnoReadScores

putlog "Loaded Color Uno $UnoVersion Copyright (C) 2004-2011 by Marky"
