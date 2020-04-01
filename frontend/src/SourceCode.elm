module SourceCode exposing (..)

import Array
import Models exposing (CodeViewer, SourceCode)


emptySourceCode : SourceCode
emptySourceCode =
    { path = "", content = Array.fromList [] }


getCodeToDisplay : CodeViewer -> SourceCode
getCodeToDisplay viewer =
    let
        beg =
            viewer.viewport.rowOffset
                |> Debug.log "beg"

        end =
            (beg
                + viewer.viewport.size.height
            )
                |> Debug.log "end"

        newTable =
            viewer.sourceCode.content
                |> Array.slice beg end
    in
    { path = viewer.sourceCode.path, content = newTable }
