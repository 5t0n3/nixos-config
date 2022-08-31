import XMonad

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import XMonad.Layout.ThreeColumns
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab

main :: IO ()
main = xmonad 
     . ewmhFullscreen 
     . ewmh 
     . withEasySB (statusBarProp "xmobar ~/.config/xmobar/xmobarrc" (pure customXmobarPP)) defToggleStrutsKey
     $ baseConfig

baseConfig = def
    { modMask = mod4Mask
    , terminal = "alacritty"
    , layoutHook = customLayout
    }
  `additionalKeysP`
    [ ("M-S-l", spawn "xscreensaver-command -lock")
    , ("M-S-s", unGrab *> spawn "scrot -s" )
    , ("M-p", spawn "rofi -show run")
    , ("<XF86MonBrightnessUp>", spawn "brightnessctl set 5%+")
    , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 5%-")
    ]

customLayout = tiled ||| Mirror tiled ||| Full
  where
    tiled = Tall nmin delta ratio
    nmin = 1 -- Default number of main windows
    ratio = 1/2 -- Default portion of screen main window takes up
    delta = 3/100 -- Step size of resizing windows

customXmobarPP :: PP
customXmobarPP = def

