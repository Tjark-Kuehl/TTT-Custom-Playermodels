new Vue({
    el: '#app',
    data: {
        exportShown: false,
        detective: [],
        player: []
    },
    computed: {
        JSON: function() {
            let obj = {}
            for (let entry in this.detective) {
                obj['detective' + (entry * 1 + 1)] = this.detective[entry]
            }
            for (let entry in this.player) {
                obj['player' + (entry * 1 + 1)] = this.player[entry]
            }
            return JSON.stringify(obj, null, 4)
        }
    },
    methods: {
        addDetective: function() {
            this.detective.push('')
        },
        removeDetective: function(idx) {
            this.detective.splice(idx, 1)
        },
        addPlayer: function() {
            this.player.push('')
        },
        removePlayer: function(idx) {
            this.player.splice(idx, 1)
        },
        exportJSON() {
            this.exportShown = !this.exportShown
            this.$nextTick(function() {
                this.$refs.textarea.focus()
                if (this.JSON && this.JSON.length) {
                    this.$refs.textarea.setSelectionRange(0, this.JSON.length)
                }
            })
        }
    }
})
