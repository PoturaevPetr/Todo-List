<template>
  <div class="flex flex  min-h-screen bg-gradient-to-br from-purple-100 via-indigo-100 to-blue-100 font-sans">
    <!-- Боковая колонка со списком проектов -->
    <aside class="w-72 bg-white bg-opacity-80 backdrop-blur-md border-r border-gray-300 rounded-xl m-2 p-2 shadow-lg">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-gray-700">Проекты</h2>
        <Icon @click="toggleProjectForm" name="pluscircle" class="w-6 h-6 text-gray-500 cursor-pointer hover:text-indigo-600 transition-colors duration-300" />
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
            <Icon name="plus" class="w-5 h-5 text-gray-600 mr-2" />
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
  if (projectName.value.trim() !== '') {
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