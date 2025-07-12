<template>
  <div class="flex flex  min-h-screen bg-gradient-to-br from-purple-100 via-indigo-100 to-blue-100 font-sans">
    <!-- Боковая колонка со списком проектов -->
    <aside class="w-72 bg-white bg-opacity-80 backdrop-blur-md border-r border-gray-300 rounded-xl m-2 p-2 shadow-lg">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-gray-700">Проекты</h2>
        <svg @click="toggleProjectForm" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
          stroke-width="1.5" stroke="currentColor"
          class="w-6 h-6 text-gray-500 cursor-pointer hover:text-indigo-600 transition-colors duration-300">
          <path stroke-linecap="round" stroke-linejoin="round"
            d="M13.5 16.875h3.375m0 0h3.375m-3.375 0V13.5m0 3.375v3.375M6 10.5h2.25a2.25 2.25 0 0 0 2.25-2.25V6a2.25 2.25 0 0 0-2.25-2.25H6A2.25 2.25 0 0 0 3.75 6v2.25A2.25 2.25 0 0 0 6 10.5Zm0 9.75h2.25A2.25 2.25 0 0 0 10.5 18v-2.25a2.25 2.25 0 0 0-2.25-2.25H6a2.25 2.25 0 0 0-2.25 2.25V18A2.25 2.25 0 0 0 6 20.25Zm9.75-9.75H18a2.25 2.25 0 0 0 2.25-2.25V6A2.25 2.25 0 0 0 18 3.75h-2.25A2.25 2.25 0 0 0 13.5 6v2.25a2.25 2.25 0 0 0 2.25 2.25Z" />
        </svg>
      </div>

      <!-- Форма создания проекта -->
      <div v-if="showProjectForm"
        class="border border-gray-300 rounded-xl p-3 bg-white bg-opacity-70 backdrop-blur-sm shadow-inner mb-4 transition-all duration-300 hover:scale-105">
        <input @keydown.enter="createProject" v-model="projectName" placeholder="Название проекта..."
          class="w-full p-2 rounded-lg border border-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-300 transition-colors duration-300 text-gray-700" />
        <div class="mt-2 flex items-center justify-between">
          <div
            class="flex items-center px-2 py-1 border border-gray-300 rounded-lg bg-gray-200 hover:bg-gray-300 cursor-pointer transition-colors duration-300"
            @click="createProject">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
              stroke="currentColor" class="w-5 h-5 text-gray-600 mr-2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            <span class="text-sm text-gray-600">Создать</span>
          </div>
          <p class="text-xs text-gray-400">нажмите Enter</p>
        </div>
      </div>

      <!-- Список проектов -->
      <ul class="mt-2">
        <li v-for="project in props.projects" :key="project.id" @click="selectProject(project.id)" :class="{
          'bg-gradient-to-r from-indigo-400 via-purple-500 to-pink-500 text-white shadow-lg': project.id === selectedProjectId,
          'bg-gray-100 hover:bg-gray-200 text-gray-700': project.id !== selectedProjectId
        }" class="p-3 rounded-xl mt-2 cursor-pointer transition-transform hover:scale-105 hover:shadow-xl">
          {{ project.name }}
        </li>
      </ul>
    </aside>

    <!-- Основная часть: контент выбранного проекта -->
    <main class="flex-1 p-2 m-2 bg-white bg-opacity-80 backdrop-blur-md rounded-xl shadow-lg">
      <div class="flex h-full w-full" v-if="currentProject">
        <!-- <h1 class="text-3xl font-bold mb-4 text-gray-700 h-10">{{ currentProject.name }}</h1> -->
        <!-- Тут можно вставить список задач или другой контент -->
        <TasksList :tasks="tasksCurrentProject" :filters="filters" :project="currentProject" :projects="projects"
          @projectDeleted="handleProjectDeleted" />
      </div>
      <div v-else class="flex items-center justify-center h-full text-gray-500 text-xl font-semibold">
        Выберите или создайте проект слева
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, defineProps } from 'vue';
import { v4 as uuidv4 } from 'uuid';
import TasksList from './TaskList.vue'

interface Project {
  id: string;       // UUID
  name: string;
  tasks: Task[];
}

interface Task {
  id: string;                        // UUID
  title: string;
  status: string;
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

const props = defineProps<{
    projects: Project[],
    filters: Filters
}>();

const showProjectForm = ref(false)
const projectName = ref<string>('');
const filters = ref<Filters>(props.filters);
const projects = ref<Project[]>(props.projects);

watch(
  () => props.projects,
  (newProjects) => {
    projects.value = newProjects;
  }
);

function toggleProjectForm() {
  showProjectForm.value = !showProjectForm.value
}



function createProject() {
  const newProject: Project = {
    id: uuidv4(),
    name: projectName.value,
    tasks: []
  }
  projects.value.push(newProject)
  projectName.value = ''
  showProjectForm.value = false
  selectProject(newProject.id)
}

const selectedProjectId = ref<string | null>(null);
const currentProject = ref<Project>()

const tasksCurrentProject = ref<Task[]>([]);

function selectProject(id: string) {
  selectedProjectId.value = id;
  const project = projects.value.find(p => p.id === id);
  if (project) {
    currentProject.value = project;
    tasksCurrentProject.value = project.tasks;
  } else {
    currentProject.value = undefined;
    tasksCurrentProject.value = [];
  }
}

function handleProjectDeleted() {
  currentProject.value = undefined
}

</script>