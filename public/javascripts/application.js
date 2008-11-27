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

var dragTimer;

/********************************
 * site-specific functions      *
 ********************************/

function startDragTimer() {
    dragTimer = new Date();
}

function dragTime() {
    return ((new Date()) - dragTimer);
}

function formatHourStr(v) {
    if (v == 12) {
        return '12pm';
    } else {
        if (v / 12 > 1) {
            return '' + v % 12 + 'pm';
        } else {
            return '' + v % 12 + 'am';
        }
    }
}

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


function setReportDates(interval) {
    startDateField = $('report_start_date');
    endDateField = $('report_end_date');
    today = new Date();
    
    switch (interval) {
        case 'last_month':
            startDate = new Date('' + today.getMonth() + '/1/' + today.getYear());
            endDate = new Date('' + (today.getMonth()+1) + '/0/' + today.getYear());
            startDateField.value = startDate.format('mm/dd/yyyy');
            endDateField.value = endDate.format('mm/dd/yyyy');
            break;
            
        case 'last_quarter':
            startMonth = Math.floor(today.getMonth() / 3) * 3 - 3;
            startDate = new Date('' + (startMonth + 1) + '/1/' + today.getYear());
            endDate = new Date('' + (startMonth + 4) + '/0/' + today.getYear());
            startDateField.value = startDate.format('mm/dd/yyyy');
            endDateField.value = endDate.format('mm/dd/yyyy');
            break;
            
        case 'last_year':
            startDate = new Date('1/1/' + (today.getYear()-1));
            endDate = new Date('12/31/' + (today.getYear()-1));
            startDateField.value = startDate.format('mm/dd/yyyy');
            endDateField.value = endDate.format('mm/dd/yyyy');
            break;
            
        case 'this_month':
            startDate = new Date('' + (today.getMonth()+1) + '/1/' + today.getYear());
            endDate = new Date('' + (today.getMonth()+2) + '/0/' + today.getYear());
            startDateField.value = startDate.format('mm/dd/yyyy');
            endDateField.value = endDate.format('mm/dd/yyyy');
            break;
            
        case 'this_quarter':
            startMonth = Math.floor(today.getMonth() / 3) * 3;
            startDate = new Date('' + (startMonth + 1) + '/1/' + today.getYear());
            endDate = new Date('' + (startMonth + 4) + '/0/' + today.getYear());
            startDateField.value = startDate.format('mm/dd/yyyy');
            endDateField.value = endDate.format('mm/dd/yyyy');
            break;
            
        case 'this_year':
            startDate = new Date('1/1/' + today.getYear());
            endDate = new Date('12/31/' + today.getYear());
            startDateField.value = startDate.format('mm/dd/yyyy');
            endDateField.value = endDate.format('mm/dd/yyyy');
            break;
        
        case 'all_time':
            startDateField.value = '01/01/2000';
            endDateField.value = '12/31/2999';
            break;
    }
}



/*
    Date Format 1.1
    (c) 2007 Steven Levithan <stevenlevithan.com>
    MIT license
    With code by Scott Trenda (Z and o flags, and enhanced brevity)
*/

/*** dateFormat
    Accepts a date, a mask, or a date and a mask.
    Returns a formatted version of the given date.
    The date defaults to the current date/time.
    The mask defaults ``"ddd mmm d yyyy HH:MM:ss"``.
*/
var dateFormat = function () {
    var token        = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloZ]|"[^"]*"|'[^']*'/g,
        timezone     = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
        timezoneClip = /[^-+\dA-Z]/g,
        pad = function (value, length) {
            value = String(value);
            length = parseInt(length) || 2;
            while (value.length < length)
                value = "0" + value;
            return value;
        };

    // Regexes and supporting functions are cached through closure
    return function (date, mask) {
        // Treat the first argument as a mask if it doesn't contain any numbers
        if (
            arguments.length == 1 &&
            (typeof date == "string" || date instanceof String) &&
            !/\d/.test(date)
        ) {
            mask = date;
            date = undefined;
        }

        date = date ? new Date(date) : new Date();
        if (isNaN(date))
            throw "invalid date";

        var dF = dateFormat;
        mask   = String(dF.masks[mask] || mask || dF.masks["default"]);

        var d = date.getDate(),
            D = date.getDay(),
            m = date.getMonth(),
            y = date.getFullYear()+1900,
            H = date.getHours(),
            M = date.getMinutes(),
            s = date.getSeconds(),
            L = date.getMilliseconds(),
            o = date.getTimezoneOffset(),
            flags = {
                d:    d,
                dd:   pad(d),
                ddd:  dF.i18n.dayNames[D],
                dddd: dF.i18n.dayNames[D + 7],
                m:    m + 1,
                mm:   pad(m + 1),
                mmm:  dF.i18n.monthNames[m],
                mmmm: dF.i18n.monthNames[m + 12],
                yy:   String(y).slice(2),
                yyyy: y,
                h:    H % 12 || 12,
                hh:   pad(H % 12 || 12),
                H:    H,
                HH:   pad(H),
                M:    M,
                MM:   pad(M),
                s:    s,
                ss:   pad(s),
                l:    pad(L, 3),
                L:    pad(L > 99 ? Math.round(L / 10) : L),
                t:    H < 12 ? "a"  : "p",
                tt:   H < 12 ? "am" : "pm",
                T:    H < 12 ? "A"  : "P",
                TT:   H < 12 ? "AM" : "PM",
                Z:    (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
                o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4)
            };

        return mask.replace(token, function ($0) {
            return ($0 in flags) ? flags[$0] : $0.slice(1, $0.length - 1);
        });
    };
}();

// Some common format strings
dateFormat.masks = {
    "default":       "ddd mmm d yyyy HH:MM:ss",
    shortDate:       "m/d/yy",
    mediumDate:      "mmm d, yyyy",
    longDate:        "mmmm d, yyyy",
    fullDate:        "dddd, mmmm d, yyyy",
    shortTime:       "h:MM TT",
    mediumTime:      "h:MM:ss TT",
    longTime:        "h:MM:ss TT Z",
    isoDate:         "yyyy-mm-dd",
    isoTime:         "HH:MM:ss",
    isoDateTime:     "yyyy-mm-dd'T'HH:MM:ss",
    isoFullDateTime: "yyyy-mm-dd'T'HH:MM:ss.lo"
};

// Internationalization strings
dateFormat.i18n = {
    dayNames: [
        "Sun", "Mon", "Tue", "Wed", "Thr", "Fri", "Sat",
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    ],
    monthNames: [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ]
};

// For convenience...
Date.prototype.format = function (mask) {
    return dateFormat(this, mask);
}
