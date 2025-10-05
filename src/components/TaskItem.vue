<template>
    <li @click="openDetails" draggable="true" @dragstart="handleDragStart"
        class="bg-white bg-opacity-80 backdrop-blur-sm p-3 rounded-xl mb-3 shadow hover:bg-gradient-to-r from-purple-100 via-indigo-100 to-blue-100 cursor-pointer transition-transform hover:scale-101 hover:shadow-xl">
        <div class="flex justify-between items-start">
            <div>
                <span class="break-all font-medium text-gray-700">{{ task.title }}</span>
            </div>
            <div>
                <Icon @click.stop="deleteTask" name="trash"
                    class="w-5 h-5 text-gray-500 hover:text-red-500 cursor-pointer transition-colors duration-300" />
            </div>
        </div>
        <div class="flex items-center mt-2">
            <div v-for="tag in task.tags" :key="tag"
                class="rounded-lg px-2 mr-1 text-orange-700 bg-orange-200 flex items-center">
                <p class="text-xs">{{ tag }}</p>
            </div>
        </div>
        <div v-if="task.subtasks.length > 0" class="flex justify-end items-center mt-2">
            <p class="text-xs text-gray-500">Вложенных: {{ task.subtasks.length }}</p>
        </div>
    </li>
</template>

<script setup lang="ts">
import { defineProps, defineEmits } from 'vue';
import Icon from './Icon.vue';

interface Task {
    id: string;
    title: string;
    status: string;
    tags: string[];
    subtasks: Task[];
    createdAt: Date;
    updatedAt: Date;
}

const props = defineProps<{
    task: Task;
}>();

const emit = defineEmits<{
    (e: 'delete-task', taskId: string): void;
    (e: 'open-details', task: Task): void;
    (e: 'drag-start', taskId: string): void;
}>();

function deleteTask() {
    emit('delete-task', props.task.id);
}

function openDetails() {
    emit('open-details', props.task);
}

function handleDragStart() {
    console.log(props.task.id)
    emit('drag-start', props.task.id);
}
</script>