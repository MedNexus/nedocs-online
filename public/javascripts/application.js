/********************************
 * site-specific settings       *
 ********************************/

var showRolloverMenuEffect = Effect.BlindDown;
var showRolloverMenuEffectOptions = { duration: 0.2 };
var hideRolloverDelay = 150;
var hideRolloverMenuEffect = Effect.BlindUp;
var hideRolloverMenuEffectOptions = { duration: 0.2 };
var showHighlight = Effect.Highlight
var showHighlightOptions = {startcolor: '#f4f4f4', endcolor: '#ffff99”', duration: .5}
var rollOverEffect = Effect.Highlight
var rollOverEffectIn = {startcolor: '#f4f4f4', endcolor: '#ffff99”', duration: .5, restorecolor: '#ffff99' }
var rollOverEffectOut = {startcolor: '#ffff99”', endcolor: '#f4f4f4', duration: .5, restorecolor: '#f4f4f4' }
var filmStripAction;


/********************************
 * site-specific functions      *
 ********************************/

function showIt(elID) {
    var el = $(elID);
    el.show();
    el.scrollIntoView(true);
}

xMousePos = 0; // Horizontal position of the mouse on the screen
yMousePos = 0; // Vertical position of the mouse on the screen
xMousePosMax = 0; // Width of the page
yMousePosMax = 0; // Height of the page

function captureMousePosition(e) {
    if (document.all) {
        xMousePos = window.event.x+document.body.scrollLeft;
        yMousePos = window.event.y+document.body.scrollTop;
        xMousePosMax = document.body.clientWidth+document.body.scrollLeft;
        yMousePosMax = document.body.clientHeight+document.body.scrollTop;
    } else if (document.getElementById) {
        xMousePos = e.pageX;
        yMousePos = e.pageY;
        xMousePosMax = window.innerWidth+window.pageXOffset;
        yMousePosMax = window.innerHeight+window.pageYOffset;
    }
    var el = $('imgThumbnail');
    var coords = getElementPosition(el);
    xMousePos -= coords[0];
    yMousePos -= coords[1];
    
    if (xMousePos >= 0 && xMousePos < 200) {
        $('zoomedImage').style.left = (-xMousePos * 5) + 269 + 'px';
    }
    
    if (yMousePos >= 0 && yMousePos < 200) {
        $('zoomedImage').style.top = (-yMousePos * 5) + 240 + 'px';
    }
}

function setHelpBubblePosition(elQuestion, elBubble, width) {
    coords = getElementPosition(elQuestion);
    
    var leftOrRight = coords[0] + width > 900;
    
    elBubble.style.position = 'absolute';
    elBubble.style.left = coords[0] + (leftOrRight ? -width : 0) + 'px';
    elBubble.style.top = coords[1] - 3 + 'px';
}

var overflowAutoDivs = $A([]);
function changeOverflowAutoToHidden() {
    $$('div').each(function (div) {
        if (div.style.overflow == 'auto') {
            overflowAutoDivs.push(div);
            div.style.overflow = 'hidden';
        }
    });
}

function changeOverflowHiddenToAuto() {
    overflowAutoDivs.each(function (div) {
        div.style.overflow = 'auto';
    });
    overflowAutoDivs = $A([]);
}

// utility function to fix # of decimal places
function setPrecision(val, p, dontPad, addCommas) {
    if (typeof(p) == 'undefined') p = 2;
    if (typeof(dontPad) == 'undefined') dontPad = false;
    if (typeof(addCommas) == 'undefined') addCommas = true;
    
    if (val.toString() == 'NaN') return '';
    var m = Math.pow(10, p);
    var ret = parseInt(Math.round(val * m), 10) / m;
    var idx = (''+ret).indexOf('.');
    if (idx < 0) {
        ret += '.';
        idx = (''+ret).indexOf('.');
    }
    
    if (!dontPad && (''+ret).substring(idx).length <= p) {
        for (var i = (''+ret).substring(idx).length; i <= p; i++) {
            ret += '0';
        }
    }
    
    if (addCommas) {
        var pieces = (''+ret).split('.');
        if (p > 0) {
            ret = '.' + pieces[1];
        } else {
            ret = pieces[1];
        }
        for (var i = 0; i < pieces[0].length; i++) {
            if (i % 3 == 2) {
                ret = ',' + pieces[0].charAt(pieces[0].length - i - 1) + ret;
            } else {
                ret = pieces[0].charAt(pieces[0].length - i - 1) + ret;
            }
        }
        ret = ret.replace(/^,/, '');
    }
    
    return ret;
}

// old bbrails function
function setTabVisibility(selected) {
    var opts = $A($('page_select').options);
    opts.each(function (opt) {
        try {
            $(opt.value).hide();
            $(opt.value + '_tab_left').style.backgroundImage = "url('/images/interface/tab_corner_left.gif')";
            $(opt.value + '_tab_center').style.backgroundImage = "url('/images/interface/tab_background.gif')";
            $(opt.value + '_tab_right').style.backgroundImage = "url('/images/interface/tab_corner_right.gif')";
        } catch (e) {}
    });
    try {
        if (selected) {
            $(selected).show();
            $('page_select').value = selected;
            $(selected + '_tab_left').style.backgroundImage = "url('/images/interface/tab_corner_left_selected.gif')";
            $(selected + '_tab_center').style.backgroundImage = "url('/images/interface/tab_background_selected.gif')";
            $(selected + '_tab_right').style.backgroundImage = "url('/images/interface/tab_corner_right_selected.gif')";
        } else {
            $($F('page_select')).show();
            $($F('page_select') + '_tab_left').style.backgroundImage = "url('/images/interface/tab_corner_left_selected.gif')";
            $($F('page_select') + '_tab_center').style.backgroundImage = "url('/images/interface/tab_background_selected.gif')";
            $($F('page_select') + '_tab_right').style.backgroundImage = "url('/images/interface/tab_corner_right_selected.gif')";
        }
    } catch (e) {}
}

function selectTab(tabName, hiddenTextFieldId) {
    $$('.tab_selected').each(function (tab) {
        tab.className = 'tab_normal';
    })
    $$('.tabinfo').each(function (tab) {
        tab.hide();
    })
    
    $('tabbtn_' + tabName).className = 'tab_selected';
    $('tabinfo_' + tabName).show();
    $(hiddenTextFieldId).value = tabName;
}


function keepOnScreen(el) {
    var el = $(el)
    el.reposition = function() {
        var y = parseInt(document.documentElement.scrollTop,10);
        if (y < this.minTop) {
            this.style.position = 'relative';
            this.style.top = '0';
        } else {
            this.style.position = 'absolute';
            this.style.top = y + 'px';
        }
        setTimeout("$('" + this.id + "').reposition();", 100);
    };
    
    el.minTop = getElementPosition(el)[1];
    el.reposition();
    
    return el;
}


function moveOntoScreen(el) {
    var el = $(el)
    if (typeof(el.minTop) == 'undefined') el.minTop = getElementPosition(el)[1];
    
    var y = parseInt(document.documentElement.scrollTop,10);
    if (y < el.minTop) {
        el.style.position = 'relative';
        el.style.top = '0';
    } else {
        el.style.position = 'absolute';
        el.style.top = y + 'px';
    }
    
    return el;
}
