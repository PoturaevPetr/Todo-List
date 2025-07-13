<template>
    <!-- Форма добавления задачи -->
    <div class="mb-4 rounded-xl rounded bg-white shadow ">
        <div class="border-1 border-gray-300 w-full rounded-xl p-1">
            <div class="flex items-center">
                <input @keydown.enter="addTask" v-model="newTaskTitle" placeholder="Название задачи..."
                    class="text-gray-500 rounded-lg p-1 w-full hover:cursor-pointer focus:outline-none" />
                <div class="">
                    <div class="flex items-center px-1 border border-gray-300 rounded-lg bg-gray-200 hover:bg-gray-300 cursor-pointer transition-colors duration-300"
                        @click="addTask">
                        <Icon @click="addTask" name="plus" class="w-5 h-5 text-gray-600 mr-2 cursor-pointer hover:text-gray-700 transition-colors"/>
                        <span class="text-sm  text-gray-600">Создать</span>
                    </div>
                    <p class="text-xs text-gray-400">нажмите Enter</p>
                </div>
            </div>
            <div class="flex items-center justify-between mt-2">
                <div class="relative inline-block dropdown-custom">
                    <div @click="toggleStatusList"
                        class="text-white flex items-center bg-gray-400 rounded-lg px-2 hover:cursor-pointer"
                        :data-value="currentStatus.value">
                        {{ currentStatus.label }}
                        <Icon name="cheveronbottom" class="w-5 h-5 ml-2"/>
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
                    <div class="flex">
                        <p v-for="tag in selectedTags" class="rounded-lg px-2 ml-1 text-orange-700 bg-orange-200 flex items-center">
                            {{ tag.label }}
                            <Icon @click.stop="removeTag(tag)" name="xmark" class="w-3 h-3 ml-2 cursor-pointer hover:text-red-600"/>
                        </p>
                    </div>
                    <div data-area-by class="relative inline-block dropdown-custom">
                        <Icon @click="toggleTagsList" name="tag" class="h-6 w-6 text-gray-500 hover:cursor-pointer hover:text-gray-70"/>
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
    task: Task;
    tags: Tags[];
    statuses: Status[];
}>()

const emit = defineEmits(['addSubTask'])

interface Status {
    label: string;
    value: string;
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

interface Status {
    label: string;
    value: string;
}

interface Tags {
    label: string;
}

const statuses = ref<Status[]>(props.statuses);
const tags = ref<Tags[]>(props.tags);
const tagInput = ref('')
const currentStatus = ref<Status>({ label: 'To Do', value: 'todo' });
const selectedTags = ref<Tags[]>([])
const showTagsList = ref(false);
const showStatusList = ref(false)
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

function toggleStatusList() {
    showStatusList.value = !showStatusList.value;
    showTagsList.value = false
}

function enterTag() {
    selectedTags.value.push({ label: tagInput.value })
    tags.value.push({ label: tagInput.value })
}

function removeTag(tag: Tags) {
    selectedTags.value = selectedTags.value.filter(t => t.label !== tag.label)
}


// Создание новой задачи
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


    props.task.subtasks.push(newTask)
    emit('addSubTask')
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