<template>
  <nav class="bg-gradient-to-r from-purple-600 via-indigo-600 to-blue-500 shadow-lg h-16 rounded-b-lg p-2 w-full">
    <div class=" mx-auto flex items-center justify-between px-6">
      <!-- Логотип и название -->
      <a href="#" class="flex items-center text-white font-bold text-xl space-x-3 hover:scale-105 transform transition-transform duration-300">
        <svg class="w-8 h-8" fill="none" stroke="white" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
        </svg>
        <span>ToDo - List</span>
      </a>
      
      <!-- Меню -->
      <Export :data="data"/>
    </div>
  </nav>
  <ProjectList :projects="projects" :filters="filters"/>
</template>

<script setup lang="ts">
import { reactive, watch , ref} from 'vue';
import ProjectList from './components/ProjectList.vue'
import Export from './components/Export.vue'

interface Project {
  id: string;
  name: string;
  tasks: Task[];
}

interface Task {
  id: string;
  title: string;
  status: 'todo' | 'in-progress' | 'done';
  tags: string[];
  subtasks: Task[];
  createdAt: Date;
  updatedAt: Date;
}

interface Filters {
  statuses: string[];
  tags: string[];
  search: string;
}

const defaultData = {
  projects: [] as Project[],
  filters: {
    statuses: [],
    tags: [],
    search: ''
  } as Filters
};

const STORAGE_KEY = 'todo_app_data'

const data = reactive(loadData());
const projects = ref<Project[]>(data.projects);
const filters = ref<Filters>(data.filters)


function loadData(): typeof defaultData {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (saved) {
    return JSON.parse(saved);
  }
  return defaultData;
}

watch(
  () => data,
  (newData) => {
    try {
      localStorage.setItem('todo_app_data', JSON.stringify(newData));
      projects.value = newData.projects
      filters.value = newData.filters
    } catch (e) {
      console.error('Ошибка сохранения данных в localStorage', e);
    }
  },
  { deep: true } // чтобы отслеживать вложенные свойства
);

</script>
