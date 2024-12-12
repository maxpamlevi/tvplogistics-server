// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

import jquery from 'jquery';
import moment from 'moment';
import select2 from 'select2';
import Toastify from 'toastify-js'
import DataTable from 'datatables.net-dt';
import "flowbite/dist/flowbite.turbo.js";
import * as agGrid from 'ag-grid-community';

import 'datatables.net-dt/css/jquery.dataTables.css';
import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-quartz.css';
import 'select2/dist/css/select2.css';
import "toastify-js/src/toastify.css"

import * as vue from 'vue/dist/vue.esm-bundler.js'

window.vue = vue

window.agGrid = agGrid
window.jQuery = jquery;
window.$ = jquery;
window.moment = moment;

select2($);

window.callToast = function (t = '', s = 4000, bg = '53397C') {
    Toastify({
        text: t,
        duration: s,
        destination: "https://github.com/apvarun/toastify-js",
        newWindow: true,
        close: true,
        gravity: "top", // `top` or `bottom`
        position: "right", // `left`, `center` or `right`
        stopOnFocus: true, // Prevents dismissing of toast on hover
        style: {
            background: 'FFFFFF',
        },
    }).showToast()
}


$.ajaxSetup({
    beforeSend: function () {
        $("div.spanner").addClass("show");
        $("div.overlay").addClass("show");
    },
    complete: function () {
        // hide progress spinner
        $("div.spanner").removeClass("show");
        $("div.overlay").removeClass("show");
    }
});


document.addEventListener('paste', function (e) {
    var clipboardData, pastedData;

    e.stopPropagation();
    e.preventDefault();

    clipboardData = e.clipboardData || window.clipboardData;
    pastedData = clipboardData.getData('Text');
    pastedData = pastedData.trim()
    document.execCommand("insertHTML", false, pastedData);
    console.log(pastedData);
});

function convertNumber(num) {
    if (!num || isNaN(parseFloat(num))) {
        return 0
    }
    if(typeof num == "number"){
        return num
    }
    return parseFloat(num.replaceAll(',', ''))

}

function convertLocalString(e){
    if(!e){
        return ''
    }
    return e.toLocaleString('en-US', {
        minimumFractionDigits: 3,
        maximumFractionDigits: 3
    });
}

function checkValueExists(arr, value) {
    return arr.some(subArr =>
        subArr
            .map(item => typeof item === 'string' ? item.trim() : item)
            .includes(value)
    );
}

window.checkValueExists = checkValueExists
window.convertNumber = convertNumber
window.convertLocalString = convertLocalString

