module CSS.All exposing (..)

import Html.Attributes exposing (..)
import Html exposing (..)

buttonStyle : List (Attribute msg)
buttonStyle =
    [ style "width" "300px"
    , style "background-color" "#6b9292"
    , style "color" "white"
    , style "padding" "14px 20px"
    , style "margin-top" "10px"
    , style "border" "none"
    , style "border-radius" "4px"
    , style "font-size" "16px"
    ]

buttonStyleHovered : List (Attribute msg)
buttonStyleHovered =
    [ style "width" "300px"
    , style "background-color" "#5fabdc"
    , style "color" "white"
    , style "padding" "14px 20px"
    , style "margin-top" "10px"
    , style "border" "none"
    , style "border-radius" "4px"
    , style "font-size" "16px"
    ]

leftStyle : List (Attribute msg)
leftStyle =
    [ style "float" "left"
    , style "margin" "auto"
    , style "display" "flex"
    , style "flexDirection" "column"
    , style "width" "40%"
    ]


rightStyle : List (Attribute msg)
rightStyle =
    [ style "overflow" "hidden"
    , style "padding" "5px"
    , style "margin" "auto"
    ]

imageStyle : List (Attribute msg)
imageStyle =
    [ style "maxHeight" "100px"
    , style "width" "160px"
    ]

leftContentStyle : List (Attribute msg)
leftContentStyle =
    [ style "marginBottom" "10px"
    , style "padding" "10px"
    , style "border" "solid 1px"
    , style "backgroundColor" "#EAFEFE"
    , style "width" "44vw"
    , style "height" "250px"
    , style "display" "flex"
    , style "flexDirection" "row"
    , style "float" "left"
    ]

rightContentStyle : List (Attribute msg)
rightContentStyle =
    [style "marginBottom" "10px"
    , style "padding" "10px"
    , style "border" "solid 1px"
    , style "backgroundColor" "#EAFEFE"
    , style "width" "44vw"
    , style "height" "250px"
    , style "display" "flex"
    , style "flexDirection" "row"
    , style "overflow" "hidden"
    ]

inputStyle : List (Attribute msg)
inputStyle =
    [ style "width" "250px"
    , style "height" "20px"
    , style "margin-bottom" "10px"
    , style "border-radius" "1px"
    ]

doubleInputStyle : List (Attribute msg)
doubleInputStyle =
    [ style "width" "250px"
    , style "height" "40px"
    , style "margin-bottom" "10px"
    , style "border-radius" "1px"
    ]

searchBarStyle : List (Attribute msg)
searchBarStyle =
    [ style "display" "flex"
    , style "justifyContent" "center"
    ]

searchInputStyle: List (Attribute msg)
searchInputStyle =
    [ style "display" "block"
    , style "width" "260px"
    , style "padding" "12px 20px"
    , style "margin" "auto"
    , style "border" "solid 2px #6b9292"
    , style "border-radius" "4px"
    ]


modalStyle : List (Attribute msg)
modalStyle =
    [style "display" "none"
    , style "position" "fixed"
    , style "z-index" "1"
    , style "left" "0"
    , style "top" "0"
    , style "overflow" "auto"
    ]

dialogContainerStyle : List (Attribute msg)
dialogContainerStyle =
    [ style "position" "absolute"
    , style "top" "20%"
    , style "bottom" "20%"
    , style "right" "20%"
    , style "left" "20%"
    , style "display" "flex"
    , style "align-items" "center"
    , style "justify-content" "center"
    , style "background-color" "#6b9292"
    , style "border" "2px solid #0a0a3a"
    , style "border-radius" "10px"
    ]

pageStyle : List (Attribute msg)
pageStyle =
    [ style "margin" "2% 2% 2% 2%"
    ]

combinedStyle : List (Attribute msg)
combinedStyle =
    [ style "padding" "10px"
    , style "display" "flex"
    ]

modalButtonStyle : List (Attribute msg)
modalButtonStyle =
    [ style "background-color" "#6b9292"
    , style "color" "white"
    , style "padding" "14px 20px"
    , style "margin-top" "10px"
    , style "border" "none"
    , style "border-radius" "4px"
    , style "font-size" "16px"
    ]