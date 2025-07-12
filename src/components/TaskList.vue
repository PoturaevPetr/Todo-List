<template>
    <div
        class="flex w-full flex-col rounded-xl bg-gradient-to-br from-purple-50  via-indigo-50 to-blue-50 font-sans p-1">
        <div class="flex items-center px-2 justify-between">
            <h3 class="w-full flex items-center justify-between text-xl font-semibold break-all mb-4 text-gray-700 cursor-pointer hover:text-gray-500"
                @click="isEditing = true" v-if="!isEditing">
                {{ currentProject.name }}
                <svg @click.stop="deleteProject(currentProject)" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                    stroke-width="1.5" stroke="currentColor"
                    class="w-5 h-5 text-gray-500 hover:text-red-500 cursor-pointer transition-colors duration-300">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                </svg>
            </h3>
            <input v-model="editedTitle" v-if="isEditing" @blur="saveTitle" @keydown.enter="saveTitle"
                class="p-1 w-full rounded-lg text-gray-700 border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 transition-colors mb-2" />
        </div>
        <TaskFilter :filters="filters" :tags="tags" :statuses="statuses"/>
        <TaskForm :tasks="tasks" :tags="tags" :statuses="statuses"/>
        <!-- Колонки задач -->
        <div class="flex space-x-2 w-full h-full">
            <!-- To Do -->
            <div class="flex-1 bg-opacity-70 backdrop-blur-md rounded-xl p-1 shadow-lg" @dragover.prevent
                @drop="handleDrop($event, 'todo')">
                <h2
                    class="text-xl font-semibold mb-4 text-gray-700 shadow-sm bg-gradient-to-r from-indigo-300 via-purple-400 to-pink-300 p-2 rounded-lg">
                    To Do</h2>
                <ul class="flex flex-col">
                    <li v-for="task in tasksByStatus['todo']" :key="task.id" @click="openTaskDetails(task)"
                        draggable="true" @dragstart="handleDragStart($event, task.id)"
                        class="bg-white bg-opacity-80 backdrop-blur-sm p-3 rounded-xl mb-3 shadow hover:bg-gradient-to-r from-purple-100 via-indigo-100 to-blue-100 cursor-pointer transition-transform hover:scale-101 hover:shadow-xl">
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="break-all font-medium text-gray-700">{{ task.title }}</span>
                            </div>
                            <div>
                                <svg @click.stop="deleteTask(task)" xmlns="http://www.w3.org/2000/svg" fill="none"
                                    viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                                    class="w-5 h-5 text-gray-500 hover:text-red-500 cursor-pointer transition-colors duration-300">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                </svg>
                            </div>
                        </div>
                        <div class="flex items-center mt-2">
                            <div v-for="tag in task.tags"
                                class="rounded-lg px-2 mr-1 text-orange-700 bg-orange-200 flex items-center">
                                <p class="text-xs">{{ tag }}</p>
                            </div>
                        </div>
                        <div v-if="task.subtasks.length > 0" class="flex justify-end items-center mt-2">
                            <p class="text-xs text-gray-500">Вложенных: {{ task.subtasks.length }}</p>
                        </div>
                    </li>
                </ul>
            </div>
            <!-- In Progress -->
            <div class="flex-1 bg-opacity-70 backdrop-blur-md rounded-xl p-1 shadow-lg" @dragover.prevent
                @drop="handleDrop($event, 'in-progress')">
                <h2
                    class="text-xl font-semibold mb-4 text-gray-700 shadow-sm bg-gradient-to-r from-indigo-300 via-purple-400 to-pink-300 p-2 rounded-lg">
                    In Progress</h2>
                <ul class="flex flex-col">
                    <li v-for="task in tasksByStatus['in-progress']" :key="task.id" @click="openTaskDetails(task)"
                        draggable="true" @dragstart="handleDragStart($event, task.id)"
                        class="bg-white bg-opacity-80 backdrop-blur-sm p-3 rounded-xl mb-3 shadow hover:bg-gradient-to-r from-purple-100 via-indigo-100 to-blue-100 cursor-pointer transition-transform hover:scale-101 hover:shadow-xl">
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="break-all font-medium text-gray-700">{{ task.title }}</span>
                            </div>
                            <div>
                                <svg @click.stop="deleteTask(task)" xmlns="http://www.w3.org/2000/svg" fill="none"
                                    viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                                    class="w-5 h-5 text-gray-500 hover:text-red-500 cursor-pointer transition-colors duration-300">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                </svg>
                            </div>
                        </div>
                        <div class="flex items-center mt-2">
                            <div v-for="tag in task.tags"
                                class="rounded-lg px-2 mr-1 text-orange-700 bg-orange-200 flex items-center">
                                <p class="text-xs">{{ tag }}</p>
                            </div>
                        </div>
                        <div v-if="task.subtasks.length > 0" class="flex justify-end items-center mt-2">
                            <p class="text-xs text-gray-500">Вложенных: {{ task.subtasks.length }}</p>
                        </div>
                    </li>
                </ul>
            </div>
            <!-- Done -->
            <div class="flex-1 bg-opacity-70 backdrop-blur-md rounded-xl p-1 shadow-lg" @dragover.prevent
                @drop="handleDrop($event, 'done')">
                <h2
                    class="text-xl font-semibold mb-4 text-gray-700 shadow-sm bg-gradient-to-r from-indigo-300 via-purple-400 to-pink-300 p-2 rounded-lg">
                    Done</h2>
                <ul class="flex flex-col">
                    <li v-for="task in tasksByStatus['done']" :key="task.id" @click="openTaskDetails(task)"
                        draggable="true" @dragstart="handleDragStart($event, task.id)"
                        class="bg-white bg-opacity-80 backdrop-blur-sm p-3 rounded-xl mb-3 shadow hover:bg-gradient-to-r from-purple-100 via-indigo-100 to-blue-100 cursor-pointer transition-transform hover:scale-101 hover:shadow-xl">
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="break-all font-medium text-gray-700">{{ task.title }}</span>
                            </div>
                            <div>
                                <svg @click.stop="deleteTask(task)" xmlns="http://www.w3.org/2000/svg" fill="none"
                                    viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                                    class="w-5 h-5 text-gray-500 hover:text-red-500 cursor-pointer transition-colors duration-300">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                </svg>
                            </div>
                        </div>
                        <div class="flex items-center mt-2">
                            <div v-for="tag in task.tags"
                                class="rounded-lg px-2 mr-1 text-orange-700 bg-orange-200 flex items-center">
                                <p class="text-xs">{{ tag }}</p>
                            </div>
                        </div>
                        <div v-if="task.subtasks.length > 0" class="flex justify-end items-center mt-2">
                            <p class="text-xs text-gray-500">Вложенных: {{ task.subtasks.length }}</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
        <!-- Детали задачи -->
        <TaskDetails v-if="selectedTask" :task="selectedTask" :tags="tags" :statuses="statuses" @close="closeTaskDetails" @delete-task="handleDeleteTask"
            @update-task="handleUpdateTask" />
    </div>
</template>

<script setup lang="ts">
import { ref, computed, defineProps, defineEmits, watch } from 'vue';
import TaskDetails from './TaskDetails.vue';
import TaskForm from './TaskForm.vue';
import TaskFilter from './TaskFilter.vue';

interface Task {
    id: string;                        // UUID
    title: string;
    status: string;
    tags: string[];
    subtasks: Task[];
    createdAt: Date;
    updatedAt: Date;
}

interface Project {
    id: string;       // UUID
    name: string;
    tasks: Task[];
}

interface Filters {
    statuses: string[];
    tags: string[];
    search: string;
}

interface Status {
    label: string;
    value: string;
}

interface Tags {
    label: string;
}

const props = defineProps<{
    tasks: Task[];
    filters: Filters;
    project: Project;
    projects: Project[];
}>();

const emit = defineEmits(['projectDeleted'])

watch(() => props.project, (project: Project) => {
    currentProject.value = project;
    editedTitle.value = currentProject.value.name
    isEditing.value = false
    closeTaskDetails()
});


const currentProject = ref<Project>(props.project)
const projects = ref<Project[]>(props.projects);
const filters = ref<Filters>(props.filters);
const tasks = computed(() => props.tasks ?? []);
const selectedTask = ref<Task | null>(null);


// Базовые статусы, можно добавить новые 
const statuses = ref<Status[]>([
    { label: 'To Do', value: 'todo' },
    { label: 'In Progress', value: 'in-progress' },
    { label: 'Done', value: 'done' }
]);

// базовый набор тэгов
const tags = ref<Tags[]>([
    { label: "Work" },
    { label: "Personal" }
]);

function openTaskDetails(task: Task) {
    closeTaskDetails()
    selectedTask.value = task;
}

function closeTaskDetails() {
    selectedTask.value = null;
}

function handleDeleteTask(taskId: string) {
    const index = tasks.value.findIndex(t => t.id === taskId);
    if (index !== -1) {
        tasks.value.splice(index, 1);
    }
    closeTaskDetails();
}

function handleUpdateTask(updatedTask: Task) {
    const index = tasks.value.findIndex(task => task.id === updatedTask.id);
    if (index !== -1) {
        tasks.value[index] = updatedTask;
    }
    selectedTask.value = updatedTask
}


const tasksByStatus = computed(() => {
    // сначала фильтруем по фильтрам
    const filtered = tasks.value.filter(task => {
        const matchesStatus = props.filters.statuses.length === 0 || props.filters.statuses.includes(task.status);
        const matchesTags = props.filters.tags.length === 0 || task.tags.some(tag => props.filters.tags.includes(tag));
        const matchesSearch = props.filters.search === '' || task.title.toLowerCase().includes(props.filters.search.toLowerCase());
        return matchesStatus && matchesTags && matchesSearch;
    });

    // группируем по статусам
    return {
        'todo': filtered.filter(task => task.status === 'todo'),
        'in-progress': filtered.filter(task => task.status === 'in-progress'),
        'done': filtered.filter(task => task.status === 'done'),
    };
});

// Метод добавления задачи

function deleteTask(task: Task) {
    const index = tasks.value.findIndex(t => t.id === task.id);
    if (index !== -1) {
        tasks.value.splice(index, 1);
    }
    closeTaskDetails()
}

function handleDrop(event: DragEvent, newStatus: string) {
    const task = tasks.value.find(t => t.id === movedTaskID.value);
    if (task) {
        task.status = newStatus;
        task.updatedAt = new Date()
    }
    if (selectedTask.value) {
        if (selectedTask.value.id == movedTaskID.value) {
            selectedTask.value.status = newStatus;
            selectedTask.value.updatedAt = new Date()
        }
    }
    movedTaskID.value = ''
}

const movedTaskID = ref<string | null>(null);

function handleDragStart(event: DragEvent, task_id: string) {
    movedTaskID.value = task_id
}

const isEditing = ref(false);
const editedTitle = ref(currentProject.value?.name)

function saveTitle() {
    if (currentProject.value) {
        if (editedTitle.value && editedTitle.value.trim() != "") {
            currentProject.value.name = editedTitle.value!;
        }
        isEditing.value = false;
    }
}

function deleteProject(project: Project) {
    const index = projects.value.findIndex(p => p.id === project.id);
    if (index !== -1) {
        projects.value.splice(index, 1);
    }
    emit('projectDeleted')
}

</script>