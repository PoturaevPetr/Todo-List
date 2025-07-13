<template>
  <!-- Используем динамический компонент, передавая имя иконки через prop -->
  <component :is="iconComponent" :class="class" />
</template>

<script lang="ts">
import { defineComponent } from 'vue'

// Импортируйте все нужные иконки
import {
  UserIcon,
  XMarkIcon,
  CogIcon
} from '@heroicons/vue/24/solid'

import { 
  PlusCircleIcon, 
  PlusIcon, 
  TrashIcon,
  Bars3Icon, 
  CloudArrowDownIcon, 
  CloudArrowUpIcon, 
  ChevronRightIcon,
  ChevronDownIcon,
  CalendarDateRangeIcon,
  TicketIcon,
  TagIcon
} from '@heroicons/vue/24/outline'

export default defineComponent({
  name: 'Icon',
  props: {
    name: {
      type: String,
      required: true,
    },
    class: {
      type: String,
      default: '',
    },
  },
  computed: {
    iconComponent() {
      // Возвращает компонент иконки по имени
      const icons: Record<string, any> = {
        user: UserIcon,
        xmark: XMarkIcon,
        cog: CogIcon,
        menu: Bars3Icon,
        pluscircle: PlusCircleIcon,
        plus: PlusIcon,
        trash: TrashIcon,
        upload: CloudArrowUpIcon,
        load: CloudArrowDownIcon,
        cheveronright: ChevronRightIcon,
        cheveronbottom: ChevronDownIcon,
        date: CalendarDateRangeIcon,
        tag: TagIcon
      }
      return icons[this.name.toLowerCase()] || null
    },
  },
})
</script>