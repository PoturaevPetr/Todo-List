<template>
  <div>
    <!-- Ваши кнопки -->
    <input type="file" ref="fileInput" class="hidden" @change="handleFileSelected" />
    <ul class="flex space-x-8 bg-white bg-opacity-20 backdrop-blur-md rounded-full shadow-md px-6 py-2">
      <!-- Импорт -->
      <li @click="triggerFileSelect">
        <a href="#" class="flex items-center text-gray-300 font-semibold hover:text-yellow-300 transition duration-300">
          <Icon name="upload" class="h-8 w-8" />
          <span class="text-lg font-semibold">Импорт</span>
        </a>
      </li>
      <!-- Экспорт -->
      <li @click="openModal('export')">
        <a href="#" class="flex items-center text-gray-300 font-semibold hover:text-yellow-300 transition duration-300">
          <Icon name="load" class="h-8 w-8" />
          <span class="text-lg font-semibold">Экспорт</span>
        </a>
      </li>
    </ul>

    <!-- Модальное окно -->
    <!-- Модальное окно с прозрачным фоном -->
    <div v-if="showModal" class="fixed inset-0 flex items-center justify-center z-50 transition-opacity duration-300">
      <div
        class="bg-white rounded-lg shadow-xl max-w-md w-full p-8 relative transform transition-transform duration-300 scale-100 hover:scale-105">
        <h2 class="text-2xl font-semibold text-center mb-6 text-gray-800">
          {{ modalAction === 'import' ? 'Введите секретный ключ для импорта' : 'Введите секретный ключ для экспорта' }}
        </h2>
        <input v-model="secretKeyInput" type="text" placeholder="Secret Key"
          class="w-full text-gray-500 border border-gray-300 rounded-lg px-4 py-3 text-lg focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition" />
        <div class="mt-6 flex justify-end space-x-4">
          <button @click="closeModal"
            class="px-4 py-2 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-lg font-semibold transition">
            Отмена
          </button>
          <button @click="confirmAction"
            class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition">
            Подтвердить
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { saveAs } from 'file-saver'; // библиотека для скачивания файлов
import CryptoJS from 'crypto-js';

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

const props = defineProps<{
  data: { projects: Project[] };
}>();

const export_data = ref(props.data);


const showModal = ref(false);
const modalAction = ref<'import' | 'export' | null>(null);
const secretKeyInput = ref('');
const secretKey = ref(''); // временно, для хранения введенного ключа
// Обработка файла для импорта
const fileInput = ref<HTMLInputElement | null>(null);
let uploadedEncryptedData = '';


// Открытие модального окна
function openModal(action: 'import' | 'export') {
  modalAction.value = action;
  secretKeyInput.value = '';
  showModal.value = true;
}

// Закрытие модального окна
function closeModal() {
  showModal.value = false;
  modalAction.value = null;
}

// логика при подтверждении
function confirmAction() {
  if (modalAction.value === 'export') {
    // экспорт
    if (!secretKeyInput.value) {
      alert('Пожалуйста, введите секретный ключ');
      return;
    }
    secretKey.value = secretKeyInput.value;
    exportToJson();
  } else if (modalAction.value === 'import') {
    // импорт
    if (!secretKeyInput.value) {
      alert('Пожалуйста, введите секретный ключ');
      return;
    }
    secretKey.value = secretKeyInput.value;
    handleFileUpload(); // вызов функции для обработки файла
  }
  closeModal();
}

// экспорт
function generateJSON() {
  return JSON.stringify(export_data.value.projects, null, 2);
}

function encryptJSON(jsonString: string, key: string): string {
  const encrypted = CryptoJS.AES.encrypt(jsonString, key).toString(); //Шифрование: AES 
  return encrypted;
}

function downloadToken(token: string) {
  const blob = new Blob([token], { type: 'application/octet-stream' });
  const filename = 'projects_encrypted.json';
  saveAs(blob, filename);
}

function exportToJson() {
  const jsonString = generateJSON();
  const encryptedToken = encryptJSON(jsonString, secretKey.value);
  downloadToken(encryptedToken);
}


function triggerFileSelect() {
  if (fileInput.value) {
    fileInput.value.value = '';
    fileInput.value.click();
  }
}

function handleFileSelected() {
  if (!fileInput.value || !fileInput.value.files || fileInput.value.files.length === 0) {
    alert('Файл не выбран.');
    return;
  }
  const file = fileInput.value.files[0];

  const reader = new FileReader();
  reader.onload = () => {
    uploadedEncryptedData = reader.result as string;
    // после выбора файла показываем окно для ввода ключа
    openModal('import')

  };
  reader.readAsText(file);
}


function handleFileUpload() {
  if (!fileInput.value || !fileInput.value.files || fileInput.value.files.length === 0) {
    alert('Файл не выбран.');
    return;
  }
  const file = fileInput.value.files[0];
  const reader = new FileReader();
  reader.onload = () => {
    uploadedEncryptedData = reader.result as string;
    decryptAndImport();
  };
  reader.readAsText(file);
}

function decryptJSON(encryptedStr: string, key: string): string | null {
  try {
    const bytes = CryptoJS.AES.decrypt(encryptedStr, key);
    const decrypted = bytes.toString(CryptoJS.enc.Utf8);
    return decrypted || null;
  } catch (e) {
    console.error('Ошибка расшифровки:', e);
    return null;
  }
}

function decryptAndImport() {
  const decryptedJson = decryptJSON(uploadedEncryptedData, secretKey.value);
  if (decryptedJson) {
    try {
      export_data.value.projects = JSON.parse(decryptedJson);
      props.data.projects = JSON.parse(decryptedJson);
    } catch (e) {
      console.error('Ошибка парсинга JSON:', e);
      alert('Ошибка при парсинге данных.');
    }
  } else {
    alert('Не удалось расшифровать файл. Проверьте правильность файла и ключа.');
  }
}
</script>