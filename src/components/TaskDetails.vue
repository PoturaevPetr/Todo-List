<template>
    <div v-if="currentTask"
        class="fixed top-0 right-0 w-1/2 h-full bg-white bg-opacity-80 backdrop-blur-md border-l border-gray-300 shadow-xl z-50 overflow-y-auto p-2 rounded-l-xl">
        <!-- Верхний блок с кнопками -->
        <div class="flex items-center justify-end mb-4 space-x-4">
            <Icon @click="deleteTask(currentTask)" name="trash" class="w-5 h-5 text-gray-500 hover:text-red-500 cursor-pointer transition-colors duration-300"/>
            <Icon @click="$emit('close')" name="xmark" class="w-6 h-6 text-gray-500 hover:text-gray-700 cursor-pointer transition-colors duration-300"/>
        </div>
        <!-- Основной контент -->
        <div class="bg-gray-50 rounded-xl p-2 shadow-inner">
            <!-- Заголовок и редактирование -->
            <div class="flex items-center">
                <h4 v-if="parentTask.length > 0" @click="showParentTask(parentTask[parentTask.length - 1])"
                    class="text-xl font-semibold break-all mb-4 text-gray-500 flex items-center hover:cursor-pointer">
                    {{ parentTask[parentTask.length - 1].title }}
                    <Icon name="cheveronright" class="w-5 h-5 mx-2"/>
                </h4>
                <h3 class="text-xl font-semibold break-all mb-4 text-gray-700 cursor-pointer hover:text-gray-500"
                    @click="isEditing = true" v-if="!isEditing">
                    {{ currentTask.title }}
                </h3>
                <input v-model="editedTitle" v-if="isEditing" @blur="saveTitle" @keydown.enter="saveTitle"
                    class="p-1 rounded-lg text-gray-700 border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 transition-colors mb-2" />

            </div>

            <!-- Статус -->
            <div class="mb-4 flex items-center">
                <strong class="mr-2 text-gray-600">Статус:</strong>
                <div class="relative dropdown-custom">
                    <div @click="toggleStatusList"
                        class="flex items-center bg-gray-400 rounded-lg px-3  cursor-pointer hover:bg-gray-300 transition-colors">
                        {{ currentStatus.label }}
                        <Icon name="cheveronbottom" class="w-4 h-4 ml-2"/>
                    </div>
                    <div v-if="showStatusList"
                        class="absolute top-full mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-300 z-50">
                        <ul>
                            <li v-for="status in statuses" :key="status.value" @click="selectStatus(status)"
                                class="px-4 py-2 hover:bg-gray-100 cursor-pointer text-gray-700">
                                {{ status.label }}
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Теги -->
            <div class="mb-4 flex items-center">
                <strong class="mr-2 text-gray-600">Теги:</strong>
                <div class="flex flex-wrap items-center space-x-2">
                    <template v-for="tag in currentTask.tags">
                        <div
                            class="flex items-center bg-orange-200 text-orange-700 rounded-lg px-3 py-1 text-xs shadow hover:bg-orange-300 transition-colors">
                            {{ tag }}
                            <Icon @click.stop="removeTag(tag)" name="xmark" class="w-3 h-3 ml-2 cursor-pointer hover:text-red-600"/>
                        </div>
                    </template>
                    <!-- Добавление тега -->
                    <div class="relative text-gray-700 dropdown-custom">
                        <Icon @click="toggleTagsList" name="plus" class="w-4 h-4 text-gray-500 cursor-pointer hover:text-gray-700 transition-colors"/>
                        <div v-if="showTagsList"
                            class="absolute top-full mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-300 z-50 p-2">
                            <input v-model="tagInput" @keydown.enter="enterTag" placeholder="Тег..."
                                class="w-full p-1 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400" />
                            <ul class="mt-2 max-h-40 overflow-y-auto">
                                <li v-for="tag in tags" :key="tag.label" @click="selectTag(tag)"
                                    class="px-2 py-1 hover:bg-gray-100 cursor-pointer rounded">
                                    {{ tag.label }}
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Даты -->
            <div class="mb-4 flex items-center space-x-4 text-gray-600 text-sm">
                <div class="flex items-center space-x-2">
                    <Icon name="date" class="w-5 h-5"/>
                    <span><strong>Создано:</strong> {{ formatDatetime(currentTask.createdAt) }}</span>
                </div>
                <div class="flex items-center space-x-2">
                    <Icon name="date" class="w-5 h-5"/>
                    <span><strong>Обновлено:</strong> {{ formatDatetime(currentTask.updatedAt) }}</span>
                </div>
            </div>

            <!-- Подзадачи -->
            <div class="mt-4 bg-gray-100 rounded-xl p-2 shadow-inner">
                <div class="flex justify-between items-center mb-2">
                    <h4 class="font-semibold text-gray-700">Подзадачи</h4>
                    <Icon @click="toggleForm" name="plus" class="w-5 h-5 text-gray-500 cursor-pointer hover:text-gray-700 transition-colors"/>
                </div>
                <div v-if="showForm" class="mb-4">
                    <SubTaskForm :task="currentTask" :tags="tags" :statuses="statuses" @addSubTask="handleAddSubTask" />
                </div>
                <ul>
                    <li v-for="task in currentTask.subtasks" :key="task.id" @click="showTaskDetails(task)"
                        class="bg-white p-3 mb-2 rounded-lg text-gray-500 shadow hover:bg-gray-200 cursor-pointer transition-colors">
                        <div class="flex justify-between items-center">
                            <span>{{ task.title }}</span>
                            <Icon @click.stop="removeSubTask(task)" name="trash" class="w-4 h-4 text-gray-400 hover:text-red-600 cursor-pointer transition-colors"/>
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
    </div>
</template>

<script setup lang="ts">
import { defineProps, defineEmits, ref, onMounted, onBeforeUnmount, watch } from 'vue';
import SubTaskForm from './SubTaskForm.vue';
import Icon from './Icon.vue';

interface Task {
    id: string;
    title: string;
    status: string;
    tags: string[];
    createdAt: Date;
    updatedAt: Date;
    subtasks: Task[];
}

interface Status {
    label: string;
    value: string;
}

interface Tags {
    label: string;
}

// Передача задачи
const props = defineProps<{
    task: Task;
    tags: Tags[];
    statuses: Status[]
}>();

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'delete-task', taskId: string): void | undefined;
    (e: 'update-task', updatedTask: Task): void | undefined;
}>();

const currentTask = ref<Task>(props.task);
const tags = ref<Tags[]>(props.tags);
const statuses = ref<Status[]>(props.statuses);
// текущая cтатус задачи
const currentStatus = ref<Status>({
    label: statuses.value.find(s => s.value === (currentTask.value?.status ?? ''))?.label ?? '',
    value: props.task.status
});
const showTagsList = ref(false);
const showStatusList = ref(false)
const tagInput = ref('')
const parentTask = ref<Task[]>([]);
const showForm = ref(false);
const isEditing = ref(false);
const editedTitle = ref(currentTask.value?.title)
const isChild = ref(false);

// если выбранная задача меняется
watch(() => props.task, (newTask: Task) => {
    currentTask.value = newTask;
    isEditing.value = false
    editedTitle.value = currentTask.value?.title
    currentStatus.value = {
        label: statuses.value.find(s => s.value === (currentTask.value?.status ?? ''))?.label ?? '',
        value: props.task.status
    };
    if (!isChild.value) {
        parentTask.value = []
    }
    isChild.value = false
});

watch(() => props.task.status, (newStatus: string) => {
    currentTask.value.status = newStatus;
    currentStatus.value = {
        label: statuses.value.find(s => s.value === (currentTask.value?.status ?? ''))?.label ?? '',
        value: props.task.status
    };
});

function formatDatetime (datetime: string) {
    return new Date(datetime).toLocaleString('ru-RU', {
      day: 'numeric',
      month: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
}

const selectTag = (tag: Tags) => {
    showTagsList.value = false; // закрываем список после выбора
    if (currentTask.value) {
        if (!currentTask.value.tags.includes(tag.label)) {
            currentTask.value.tags.push(tag.label)
        }
        currentTask.value.updatedAt = new Date();
    }
};

const removeTag = (tag: string) => {
    if (currentTask.value) {
        currentTask.value.tags = currentTask.value.tags.filter(t => t !== tag);
        currentTask.value.updatedAt = new Date();
    }
}

const selectStatus = (status: Status) => {
    if (currentTask.value) {
        currentTask.value.status = status.value
        currentTask.value.updatedAt = new Date();
    }
    showStatusList.value = false; // закрываем список после выбора
};

function enterTag() {
    currentTask.value?.tags.push(tagInput.value)
    tags.value.push({ label: tagInput.value })
    tagInput.value = ''
    if (currentTask.value) {
        currentTask.value.updatedAt = new Date();
    }
    showTagsList.value = false; // закрываем список после выбора
}

function showParentTask(task: Task) {
    isEditing.value = false
    parentTask.value.pop()
    currentTask.value = task
    editedTitle.value = currentTask.value.title
    currentStatus.value = {
        label: statuses.value.find(s => s.value === (currentTask.value?.status ?? ''))?.label ?? '',
        value: currentTask.value.status
    };
}

function showTaskDetails(task: Task) {
    isChild.value = true
    parentTask.value.push({ ...currentTask.value })
    isEditing.value = false
    currentTask.value = task
    editedTitle.value = currentTask.value.title
    currentStatus.value = {
        label: statuses.value.find(s => s.value === (currentTask.value?.status ?? ''))?.label ?? '',
        value: currentTask.value.status
    };
    emit('update-task', currentTask.value)
}

// Локальная переменная для новой подзадачи

function deleteTask(task: Task) {
    if (parentTask.value.length > 0) {
        const index = parentTask.value[parentTask.value.length - 1].subtasks.findIndex(t => t.id === task.id);
        if (index !== -1) {
            parentTask.value[parentTask.value.length - 1].subtasks.splice(index, 1);
        }
        showParentTask(parentTask.value[parentTask.value.length - 1])
    } else {
        emit('delete-task', task.id);
    }
}

function toggleForm() {
    showForm.value = !showForm.value;
}

function toggleTagsList() {
    showTagsList.value = !showTagsList.value;
    showStatusList.value = false;
}

function toggleStatusList() {
    showStatusList.value = !showStatusList.value;
    showTagsList.value = false
}

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

function removeSubTask(task: Task) {
    if (currentTask.value) {
        const index = currentTask.value.subtasks.findIndex(t => t.id === task.id);
        if (index !== -1) {
            currentTask.value.subtasks.splice(index, 1);
        }
    }
}

function saveTitle() {
    if (currentTask.value) {
        if (editedTitle.value && editedTitle.value.trim() != "") {
            currentTask.value.title = editedTitle.value!;
            currentTask.value.updatedAt = new Date();
            emit('update-task', currentTask.value)
        }
        isEditing.value = false;
    }
}

function handleAddSubTask() {
    currentTask.value.updatedAt = new Date();
}
</script>