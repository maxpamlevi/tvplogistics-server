// const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')


module.exports = {
    content: [
        './public/*.html',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.js',
        './app/views/**/*.{erb,haml,html,slim}',
        './node_modules/flowbite/**/*.js'
    ],
    theme: {
        defaultTheme,
        colors: colors,
    },
    plugins: [
        require('flowbite/plugin'),
    ]
}
