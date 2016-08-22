'use strict';

var photoAmount = undefined;
var userID = '';
var queryID = 'H8m6LDDntM';
var totalAmount = 200;
var userName = undefined;
var seed = undefined;
var curIndex = 1;
var curObj = undefined;
var result = [];

var bigFive = [{
    personality: 'Openness',
    terms: [{
        name: 'Curious',
        chinese: '好奇的'
    }, {
        name: 'Intellectual',
        chinese: '理智的'
    }, {
        name: 'Creative',
        chinese: '有創意的'
    }, {
        name: 'Narrow Interest',
        chinese: '興趣狹窄的'
    }]
}, {
    personality: 'Conscientiousness',
    terms: [{
        name: 'Responsible',
        chinese: '負責任的'
    }, {
        name: 'Organized',
        chinese: '有組織的'
    }, {
        name: 'Neat',
        chinese: '細緻的'
    }, {
        name: 'Hedonistic',
        chinese: '好玩樂的'
    }]
}, {
    personality: 'Extraversion',
    terms: [{
        name: 'Outgoing',
        chinese: '外向的'
    }, {
        name: 'Withdrawn',
        chinese: '退縮的'
    }, {
        name: 'Silent',
        chinese: '沈默的'
    }, {
        name: 'unsocial',
        chinese: '不善社交的'
    }]
}, {
    personality: 'Agreeableness',
    terms: [{
        name: 'Cooperative',
        chinese: '合作的'
    }, {
        name: 'Modest',
        chinese: '謙遜的'
    }, {
        name: 'Irritable',
        chinese: '易怒的'
    }, {
        name: 'Impolite',
        chinese: '無禮的'
    }]
}, {
    personality: 'Neuroticism',
    terms: [{
        name: 'Secure',
        chinese: '使人安心的'
    }, {
        name: 'Hardy',
        chinese: '堅毅的'
    }, {
        name: 'Unemotional',
        chinese: '缺乏感情的'
    }, {
        name: 'Nervous',
        chinese: '易緊張的'
    }]
}];

var labelAnsTemp = {
    photo: '',
    notUsed: false,
    tag: []
};

// Options tag --------------------------------------------------

Handlebars.registerHelper('moduloIf', function (index, pos, mod, options) {
    if (parseInt(index) % mod === pos) return options.fn(undefined);
});

var source = $('#option-template').html();
var template = Handlebars.compile(source);
var optionsHtml = template(bigFive);
$(optionsHtml).prependTo('#options');

// --------------------------------------------------

var init = function init() {
    var label = Object.assign({}, labelAnsTemp);
    var photoIndex = (photoAmount * seed + curIndex - 1) % totalAmount + 1;
    label.photo = photoIndex + '.jpg';
    $('#portrait').attr('src', 'images/' + photoIndex + '.jpg');
    $('.progress-tag').html(curIndex + '/' + photoAmount);

    return label;
};

var checkFill = function checkFill() {
    if ($(':input').serializeArray().length === 0) return false;else return true;
};

var checkBound = function checkBound(index) {
    if (index === 1) return 'head';else if (index === photoAmount) return 'end';else if (index < 1 || index > photoAmount) return 'out';else return false;
};

var changeIndex = function changeIndex(direction) {
    if (direction === 'next') {
        // save
        result.push(curObj);
        saveStorage();
        //check bound
        var bound = checkBound(++curIndex);
        if (bound === 'end') $('#arrow-right').html('完成');
        if (bound !== 'out') {
            resetView();
            curObj = init();
        } else {
            curIndex = photoAmount;
            $('#js-doneDialog').modal('show');
        }

        $('#arrow-left').show();
    } else if (direction === 'previous') {
        //load
        curObj = result.pop();
        //check bound
        var bound = checkBound(--curIndex);
        if (bound === 'head') $('#arrow-left').hide();
        if (bound !== 'out') {
            resetView();
            load2View(curObj);
        } else curIndex = 1;

        $('#arrow-right').html('');
    }
};

var load2View = function load2View(data) {
    var photoIndex = (photoAmount * seed + curIndex - 1) % totalAmount + 1;
    $('#portrait').attr('src', 'images/' + photoIndex + '.jpg');
    $('.progress-tag').html(curIndex + '/' + photoAmount);

    if (data.notUsed === true) {
        $('input[name="notUsed"]').prop('checked', true);
        $('#options').collapse('hide');
    } else {
        data.tag.forEach(function (element) {
            $('[name=\'' + element + '\']').click();
        });
    }
    if (curIndex === 1) $('#arrow-left').hide();
};

var resetView = function resetView() {
    $('label.tag').removeClass('active');
    $('#options').addClass('in');
    $(':input').prop('checked', false);
};

var saveStorage = function saveStorage() {
    localStorage.userID = userID;
    localStorage.seed = seed;
    localStorage.result = JSON.stringify(result);
    localStorage.curIndex = curIndex;
};

var loadStorage = function loadStorage() {
    userID = localStorage.userID;
    seed = localStorage.seed;
    result = JSON.parse(localStorage.result);
    curIndex = parseInt(localStorage.curIndex);
    curObj = result.pop();
    $('.field-id').val(userID);
    load2View(curObj);
};

Parse.initialize('tBB8F97hfDVsjuFvM3tqpcQOfYHqSKdXW8tHeitO', '8XiZEz5t7w3ONN5BpbZeR1TxZxrG5hKQQcqtFVCV');
var User = Parse.Object.extend('Users');
var userQuery = new Parse.Query(User);
var PhotoAmount = Parse.Object.extend('PhotoAmount');
var amountQuery = new Parse.Query(PhotoAmount);

if (localStorage.result !== undefined) {
    loadStorage();
}

//---------------------------------------------------

// Listeners
$('.login').click(function () {
    // load user info
    userID = $('.field-id').val();
    userQuery.get(userID).then(function (resultObj) {
        userName = resultObj.get('Name');
        seed = resultObj.get('Seed');
        $('.loginView').slideUp(400);
        $('.title').prepend(userName + '，請問');
    }, function () {
        $('.field-id').attr('placeholder', '輸入錯誤，請再次輸入 ID');
    }).then(function () {
        // load amount
        amountQuery.get(queryID).then(function (resultObj) {
            photoAmount = resultObj.get('amount');
        }, function () {
            photoAmount = 200;
        }).then(function () {
            if (localStorage.resultObj === undefined) {
                curObj = init();
                $('#arrow-left').hide();
            } else {
                loadStorage();
            }
        });
    });
});

$(document).on('keydown', function (event) {
    if (event.which === 39) {
        if (!checkFill()) {
            alert('麻煩你標記圖片屬性！');
            return;
        }
        changeIndex('next');
    } else if (event.which === 37) {
        changeIndex('previous');
    }
});

$('.arrows').click(function () {
    if ($(this).attr('id') === 'arrow-right') {
        if (!checkFill()) {
            alert('麻煩你標記圖片屬性！');
            return;
        }
        changeIndex('next');
    } else {
        changeIndex('previous');
    }
});

// hide options
$('.not-used').click(function () {
    $('#options').collapse('toggle');
});

$('form :input').on('change', function () {
    var field = $(':input').serializeArray();
    var labels = undefined;
    if (field.find(function (ele) {
        return ele.name === 'notUsed';
    })) {
        curObj.notUsed = true;
        curObj.tag = [];
    } else {
        labels = field.map(function (element) {
            return element.name;
        });
        curObj.tag = labels;
    }
});

// Parse Save

Parse.initialize('tBB8F97hfDVsjuFvM3tqpcQOfYHqSKdXW8tHeitO', '8XiZEz5t7w3ONN5BpbZeR1TxZxrG5hKQQcqtFVCV');
var PhotoLabels = Parse.Object.extend('PhotoLabels');
var parseLabel = new PhotoLabels();

$('.submit').click(function () {
    var $btn = $(this).button('loading');
    parseLabel.save({
        result: result,
        User: userName
    }).then(function () {
        $btn.button('reset');
        $('#js-doneDialog').modal('hide');
        $('#js-saveInfo').modal('show');
    }, function () {
        alert('上傳失敗！請再試一次！');
        $btn.button('reset');
    });
});
