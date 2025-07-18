import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import Icon from './components/Icon.vue' // ваш компонент

const app = createApp(App)
app.component('Icon', Icon) 

app.mount('#app')
