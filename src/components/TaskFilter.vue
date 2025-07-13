<template>
    <div class="flex justify-between items-center bg-white shadow-xl mb-2 w-full rounded-xl p-2">
        <div class="flex items-center">
            <p class="text-gray-500">Фильтры</p>
            <div class="ml-2 px-2 py-1 rounded-lg flex items-center bg-gray-100">
                <p class="text-gray-500">Тэги</p>
                <div class="flex items-center">
                    <div v-for="tag in selectedTagsList"
                        class="rounded-lg px-2 ml-1 text-orange-700 bg-orange-200 flex items-center">
                        <p class="text-xs">{{ tag }}</p>
                        <Icon @click.stop="removeTag(tag)" name="xmark" class="w-3 h-3 ml-2 cursor-pointer hover:text-red-600"/>
                    </div>
                </div>
                <div class="relative inline-block dropdown-custom">
                    <Icon @click="toggleTagsList" name="pluscircle" class="h-5 w-5 ml-2 text-gray-500 hover:text-gray-700"/>
                    <div v-if="showTagsList"
                        class="absolute left-0 top-5 mt-2 w-48 bg-white border border-gray-300 rounded-lg shadow-lg z-50">
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
            <div class="ml-2 px-2 py-1 rounded-lg flex items-center bg-gray-100">
                <p class="text-gray-500">Статусы</p>
                <div class="flex items-center">
                    <div v-for="status in statuses.filter(s => selectedStatusList.includes(s.value))"
                        class="rounded-lg text-white px-2 ml-1 bg-gray-400 flex items-center">
                        <p class="text-white text-xs">{{ status.label }}</p>
                        <Icon @click.stop="removeStatus(status)" name="xmark" class="w-3 h-3 ml-2 hover:cursor-pointer"/>
                    </div>
                </div>
                <div class="relative inline-block dropdown-custom">
                    <Icon @click="toggleStatusList" name="pluscircle" class="h-5 w-5 ml-2 text-gray-500 hover:text-gray-700"/>
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
            </div>
        </div>

        <input v-model="inputSearch" @input="onInputSearch" placeholder="Поиск..."
            class="p-1 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-indigo-300 transition-colors duration-300 text-gray-700" />
    </div>
</template>

<script setup lang="ts">
import { ref, defineProps, onMounted, onBeforeUnmount } from 'vue';

interface Filters {
    statuses: string[];
    tags: string[];
    search: string;
}

const props = defineProps<{
    filters: Filters;
    tags: Tags[],
    statuses: Status[]
}>();

const filters = ref<Filters>(props.filters);

interface Tags {
    label: string;
}

interface Status {
    label: string;
    value: string;
}

const tags = ref<Tags[]>(props.tags);
const statuses = ref<Status[]>(props.statuses);
const inputSearch = ref<string>('')
const tagInput = ref('')
const showTagsList = ref(false);
const showStatusList = ref(false)
const selectedTagsList = ref<string[]>([]);
const selectedStatusList = ref<string[]>([]);

//  Подтянуть фильтры из localStorage
selectedTagsList.value = filters.value.tags
selectedStatusList.value = filters.value.statuses
inputSearch.value = filters.value.search

function toggleTagsList() {
    showTagsList.value = !showTagsList.value;
    showStatusList.value = false;
}

function toggleStatusList() {
    showStatusList.value = !showStatusList.value;
    showTagsList.value = false
}

const selectTag = (tag: Tags) => {
    if (!selectedTagsList.value.includes(tag.label)) {
        selectedTagsList.value.push(tag.label)
        filters.value.tags = selectedTagsList.value
    }
    showTagsList.value = false
};

function enterTag() {
    selectedTagsList.value.push(tagInput.value)
    tags.value.push({ label: tagInput.value })
}

function onInputSearch() {
    filters.value.search = inputSearch.value
}

const removeTag = (tag: string) => {
    selectedTagsList.value = selectedTagsList.value.filter(t => t !== tag);
    filters.value.tags = selectedTagsList.value
}

const removeStatus = (status: Status) => {
    selectedStatusList.value = selectedStatusList.value.filter(s => s !== status.value);
    filters.value.statuses = selectedStatusList.value
}

const selectStatus = (status: Status) => {
    if (!selectedStatusList.value.includes(status.value)) {
        selectedStatusList.value.push(status.value)
        filters.value.statuses = selectedStatusList.value
    }
    showStatusList.value = false;
};

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