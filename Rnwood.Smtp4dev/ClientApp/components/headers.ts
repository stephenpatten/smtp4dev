import { Component, Prop, Watch } from 'vue-property-decorator';
import Vue from 'vue'
import Header from "../ApiClient/Header";
import { ElTable } from 'element-ui/types/table';

@Component
export default class Headers extends Vue {
    constructor() {
        super(); 
    }

    @Prop()
    headers: Header[] = [];


    doLayout() {
        (<ElTable>(this.$refs).table).doLayout();
    }

    async destroyed() {
        
    }


}