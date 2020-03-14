module Models exposing (..)


type Msg
    = NoOp
    | MoveCursor Movement
    | JumpCursor


type Movement = RightOneChar
              | LeftOneChar
              | UpOneChar
              | DownOneChar


type alias Pos = ( Int, Int )


type alias Size =
    { width: Int
    , height: Int
    }

