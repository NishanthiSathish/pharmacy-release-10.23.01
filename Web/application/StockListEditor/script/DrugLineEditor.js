function drugLineEditor_onresize() 
{
    // Position imgRevertDescription
    var tbDescription        = $('.' + ICW.Controls.CSS.CONTROL_SHORTTEXT + '[id$=tbDescription] input:eq(0)');
    var imgRevertDescription = $('input[id$=imgRevertDescription]');
    if (tbDescription.length > 0)
    {
        imgRevertDescription.css({ top:  tbDescription.offset().top, 
                                    left: tbDescription.offset().left + tbDescription.width() + 6 });
                            }

    // Position imgRevertPackSize
    var numPackSize = $('.' + ICW.Controls.CSS.CONTROL_NUMBER + '[id$=numPackSize] span.suffix');
    var imgRevertPackSize = $('input[id$=imgRevertPackSize]');
    if (numPackSize.length > 0)
    {
        imgRevertPackSize.css({ top:  numPackSize.offset().top - 3, 
                                left: numPackSize.offset().left + numPackSize.width() + 6 });
    }
}