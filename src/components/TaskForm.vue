<template>
    <!-- Форма добавления задачи -->
    <div class="mb-4 h-36 p-4 border rounded-xl bg-white shadow ">
        <h3 class="mb-2 font-semibold text-gray-700">Добавить новую задачу</h3>
        <div class="border-1 border-gray-300 w-full rounded-xl p-1">
            <div class="flex items-center">
                <input @keydown.enter="addTask" v-model="newTaskTitle" placeholder="Название задачи..."
                    class="text-gray-500 rounded-lg p-1 w-full hover:cursor-pointer focus:outline-none" />
                <div class="">
                    <div class="flex items-center px-1 border border-gray-300 rounded-lg bg-gray-200 hover:bg-gray-300 cursor-pointer transition-colors duration-300"
                        @click="addTask">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                            stroke="currentColor" class="w-5 h-5 text-gray-600 mr-2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                        </svg>
                        <span class="text-sm  text-gray-600">Создать</span>
                    </div>
                    <p class="text-xs text-gray-400">нажмите Enter</p>
                </div>
            </div>
            <div class="flex items-center justify-between mt-2">
                <div class="relative inline-block dropdown-custom">
                    <div @click="toggleStatusList"
                        class="text-white flex items-center bg-gray-400 rounded-lg pl-2 hover:cursor-pointer"
                        :data-value="currentStatus.value">
                        {{ currentStatus.label }}
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                            stroke="currentColor" class="size-5">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M8.25 15 12 18.75 15.75 15m-7.5-6L12 5.25 15.75 9" />
                        </svg>
                    </div>
                    <div v-if="showStatusList"
                        class="absolute left-0 top-5 mt-2 w-48 bg-white border border-gray-300 rounded-lg shadow-lg z-50">
                        <ul class="py-2">
                            <li v-for="status in statuses" :key="status.value" @click="selectStatus(status)"
                                class="px-4 text-gray-500 hover:bg-gray-100 cursor-pointer" :data-value="status.value">
                                {{ status.label }}
                            </li>
                        </ul>
                    </div>
                </div>
                <div class="flex items-center">
                    <div class="flex items-center">
                        <p v-for="tag in selectedTags" class="rounded-lg px-2 ml-1 text-orange-700 bg-orange-200 flex items-center">
                            {{ tag.label }}
                            <svg @click.stop="removeTag(tag)" xmlns="http://www.w3.org/2000/svg"
                                class="w-3 h-3 ml-2 cursor-pointer hover:text-red-600" fill="none" viewBox="0 0 24 24"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                    d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </p>
                    </div>
                    <div data-area-by class="relative inline-block dropdown-custom">
                        <svg @click="toggleTagsList" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                            stroke-width="1.5" stroke="currentColor"
                            class="size-6 text-gray-500 hover:cursor-pointer hover:text-gray-700">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M9.568 3H5.25A2.25 2.25 0 0 0 3 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 0 0 5.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 0 0 9.568 3Z" />
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 6h.008v.008H6V6Z" />
                        </svg>
                        <div v-if="showTagsList"
                            class="absolute right-0 top-5 mt-2 w-48 bg-white border border-gray-300 rounded-lg shadow-lg z-50">
                            <input v-model="tagInput" @keydown.enter="enterTag" placeholder="Тег..."
                                class="text-gray-500 rounded-lg p-1 px-2 w-full hover:cursor-pointer focus:outline-none" />
                            <ul class="py-2">
                                <li v-for="tag in tags" @click="selectTag(tag)"
                                    class="px-4 text-gray-500 hover:bg-gray-100 cursor-pointer">
                                    {{ tag.label }}
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, defineEmits } from 'vue';
import { v4 as uuidv4 } from 'uuid';
const props = defineProps<{
  tasks: Task[];
  tags: Tags[];
  statuses: Status[];
}>()

interface Task {
    id: string;
    title: string;
    status: string;
    tags: string[];
    subtasks: Task[];
    createdAt: Date;
    updatedAt: Date;
}

interface Status {
    label: string;
    value: string;
}

interface Tags {
    label: string;
}

const statuses = ref<Status[]>(props.statuses);
const tags = ref<Tags[]>(props.tags);
const currentStatus = ref<Status>({ label: 'To Do', value: 'todo' });
const selectedTags = ref<Tags[]>([])
const showTagsList = ref(false);
const showStatusList = ref(false)
const tagInput = ref('')
const newTaskTitle = ref('');

const selectStatus = (status: Status) => {
    currentStatus.value = status;
    showStatusList.value = false; // закрываем список после выбора
};

const selectTag = (tag: Tags) => {
    selectedTags.value.push(tag)
    showTagsList.value = false; // закрываем список после выбора
};

function toggleTagsList() {
    showTagsList.value = !showTagsList.value;
    showStatusList.value = false;
}

const removeTag = (tag:Tags) => {
    selectedTags.value = selectedTags.value.filter(t => t.label !== tag.label)
}

function toggleStatusList() {
    showStatusList.value = !showStatusList.value;
    showTagsList.value = false
}

function enterTag() {
    selectedTags.value.push({ label: tagInput.value })
    tags.value.push({ label: tagInput.value })
}

function addTask() {
    if (newTaskTitle.value.trim() === '') return;

    const newTask: Task = {
        id: uuidv4(), // Можно использовать UUID, если есть библиотека
        title: newTaskTitle.value,
        status: currentStatus.value.value,
        tags: selectedTags.value.map(tag => tag.label.trim()),
        subtasks: [],
        createdAt: new Date(),
        updatedAt: new Date(),
    };
    props.tasks.push(newTask)
    // Очистка формы
    newTaskTitle.value = '';
    selectedTags.value = [];
}

// обработка кликов вне .dropdown-custom
const handleClickOutside = (event: MouseEvent) => {
    const target = event.target as HTMLElement | null;
    if (!target || !target.closest('.dropdown-custom')) {
        showStatusList.value = false;
        showTagsList.value = false
    }
};

onMounted(() => {
    document.addEventListener('click', handleClickOutside);
});

onBeforeUnmount(() => {
    document.removeEventListener('click', handleClickOutside);
});



</script>